#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Installing Docker"
yum update -y
yum install -y docker
service docker start
usermod -a -G docker ec2-user

echo "Installing Docker Compose"
curl -L https://github.com/docker/compose/releases/download/1.23.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

echo "Creating the http status config file"
cat << EOF > /opt/deploy/url.yaml
init_config:

instances:
  - name: Drupal Service
    url: https://cms-challenge.ddns.net:8888/core/install.php
    disable_ssl_validation: false
    check_certificate_expiration: true
    days_warning: 28
    days_critical: 14
    timeout: 3
EOF

echo "Creating the docker-compose.yml file"
mkdir -p /opt/deploy/
cat << EOF > /opt/deploy/docker-compose.yml
version: "3.1"
services:
  postgres:
    image: postgres:9.6
    labels:
      com.datadoghq.ad.logs: '[{"source": "postgres", "service": "postgres"}]'
    container_name: db
    ports:
      - 5432:5432
    environment:
      POSTGRES_PASSWORD: D3v0psCha113ng3
    restart: always
    volumes:
      - 'postgres_data:/var/lib/postgresql/data'

  datadog:
    image: datadog/agent:latest
    container_name: ddagent
    environment:
     - DD_API_KEY=${datadog_api_key}
     - DD_LOGS_ENABLED=true
     - DD_LOGS_CONFIG_CONTAINER_COLLECT_ALL=true
     - DD_AC_EXCLUDE="name:datadog-agent"
    volumes:
     - /var/run/docker.sock:/var/run/docker.sock
     - /proc/:/host/proc/:ro
     - /opt/datadog-agent/run:/opt/datadog-agent/run:rw
     - /sys/fs/cgroup/:/host/sys/fs/cgroup:ro
     - /opt/deploy/url.yaml:/etc/datadog-agent/conf.d/http_check.d/url.yaml

volumes:
  postgres_data:
    driver: local
EOF

echo "Starting containers"
/usr/local/bin/docker-compose -f /opt/deploy/docker-compose.yml up -d
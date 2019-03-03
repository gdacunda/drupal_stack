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
     - DD_API_KEY=6d06a8f4b2d864a241ee9394e96399c8
     - DD_LOGS_ENABLED=true
     - DD_LOGS_CONFIG_CONTAINER_COLLECT_ALL=true
     - DD_AC_EXCLUDE="name:datadog-agent"
    volumes:
     - /var/run/docker.sock:/var/run/docker.sock
     - /proc/:/host/proc/:ro
     - /opt/datadog-agent/run:/opt/datadog-agent/run:rw
     - /sys/fs/cgroup/:/host/sys/fs/cgroup:ro


volumes:
  postgres_data:
    driver: local
EOF

echo "Starting containers"
/usr/local/bin/docker-compose -f /opt/deploy/docker-compose.yml up -d
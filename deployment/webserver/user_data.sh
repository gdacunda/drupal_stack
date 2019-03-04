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

echo "Mounting efs drive"
yum install -y nfs-utils amazon-efs-utils
mkdir -p /mnt/efs-data/
echo "${efs_system_id}:/ /mnt/efs-data efs tls,_netdev" >> /etc/fstab
mount -a -t efs defaults

mkdir -p /mnt/efs-data/drupal-data/ \
         /mnt/efs-data/drupal-data/profiles \
         /mnt/efs-data/drupal-data/modules \
         /mnt/efs-data/drupal-data/files
chown ec2-user:ec2-user /mnt/efs-data
chown -R 33:33 /mnt/efs-data/drupal-data


echo "Creating the Drupal config file"
cat << EOF > /mnt/efs-data/drupal-data/settings.php
\$databases['default']['default'] = array (
  'database' => 'drupal',
  'username' => 'postgres',
  'password' => 'D3v0psCha113ng3',
  'prefix' => '',
  'host' => '${database_host}',
  'port' => '5432',
  'namespace' => 'Drupal\\Core\\Database\\Driver\\pgsql',
  'driver' => 'pgsql',
);
$settings['install_profile'] = 'standard';
EOF
chown -R 33:33 /mnt/efs-data/drupal-data/settings.php
chmod 0644 /mnt/efs-data/drupal-data/settings.php

echo "Creating the docker-compose.yml file"
mkdir -p /opt/deploy/
cat << EOF > /opt/deploy/docker-compose.yml
version: "3.1"
services:
  web:
    image: gdacunda/drupal:${webserver_image_tag}
    labels:
      com.datadoghq.ad.logs: '[{"source": "apache", "service": "drupal"}]'
    ports:
      - 8888:80
    volumes:
      - /mnt/efs-data/drupal-data/modules:/var/www/html/modules
      - /mnt/efs-data/drupal-data/profiles:/var/www/html/profiles
      - /mnt/efs-data/drupal-data/files:/var/www/html/sites/default/files
      - /mnt/efs-data/drupal-data/settings.php:/var/www/html/sites/default/settings.php
    container_name: web
    restart: always

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
EOF

echo "Starting containers"
/usr/local/bin/docker-compose -f /opt/deploy/docker-compose.yml up -d
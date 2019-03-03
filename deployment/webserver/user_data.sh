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
sudo mkdir -p /mnt/efs-data/
echo "${efs_system_id}:/ /mnt/efs-data efs tls,_netdev" >> /etc/fstab
mount -a -t efs defaults

sudo mkdir -p /mnt/efs-data/drupal-data/
chown ec2-user:ec2-user /mnt/efs-data
chown -R 33:33 /mnt/efs-data/drupal-data

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
      - /var/www/html/modules
      - /var/www/html/profiles
      - /var/www/html/themes
      - /mnt/efs-data/drupal-data:/var/www/html/sites/default/files
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
     - /proc/mounts:/host/proc/mounts:ro
     - /sys/fs/cgroup:/host/sys/fs/cgroup:ro
EOF

echo "Starting containers"
/usr/local/bin/docker-compose -f /opt/deploy/docker-compose.yml up -d
#!/usr/bin/env bash

# install docker
yum update -y
yum install -y docker
service docker start
usermod -a -G docker ec2-user

# install compose
curl -L https://github.com/docker/compose/releases/download/1.23.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
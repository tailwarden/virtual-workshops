#!/bin/bash

echo "Install Java JDK 11"
yum update -y
yum install -y java-11-amazon-corretto-devel jq

echo "Install Docker engine"
yum install docker -y
usermod -aG docker ec2-user
systemctl enable docker

echo "Install git"
yum install -y git
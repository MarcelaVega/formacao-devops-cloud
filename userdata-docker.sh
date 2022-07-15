#!/bin/bash
yum update -y
yum upgrade -y
yum install htop zip unzip -y
echo "ECS_CLUSTER=wordpress-cluster" >> /etc/ecs/ecs.config
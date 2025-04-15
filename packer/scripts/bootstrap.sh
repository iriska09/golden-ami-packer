#!/bin/bash
# Install Ansible prerequisites
set -e

echo "Running bootstrap script..."

if [ -f /etc/redhat-release ]; then
    # Amazon Linux/CentOS/RHEL
    sudo yum update -y
    sudo yum install -y python3 python3-pip
elif [ -f /etc/lsb-release ]; then
    # Ubuntu
    sudo apt-get update -y
    sudo apt-get install -y python3 python3-pip
else
    echo "Unsupported OS"
    exit 1
fi

sudo pip3 install ansible

echo "Bootstrap completed successfully"
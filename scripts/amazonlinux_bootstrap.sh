#!/bin/bash

# Set strict mode
set -euo pipefail

# Update system
echo "Updating system packages..."
sudo yum update -y

# Install dependencies for Ansible
echo "Installing Python and dependencies..."
sudo yum install -y python3 python3-pip git

# Install Ansible
echo "Installing Ansible..."
sudo pip3 install ansible==7.1.0

# Clean up
echo "Cleaning up..."
sudo yum clean all
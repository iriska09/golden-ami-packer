#!/bin/bash

# Set strict mode
set -euo pipefail

# Update system
echo "Updating system packages..."
sudo yum update -y

# Install dependencies
echo "Installing Python and Ansible..."
sudo yum install -y python3 python3-pip git ansible

# Clean up
echo "Cleaning up..."
sudo yum clean all

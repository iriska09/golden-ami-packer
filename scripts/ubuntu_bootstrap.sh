#!/bin/bash

# Set strict mode
set -euo pipefail

# Update system
echo "Updating system packages..."
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# Install dependencies for Ansible
echo "Installing Python and dependencies..."
sudo apt-get install -y python3 python3-pip python3-venv git

# Install Ansible
echo "Installing Ansible..."
sudo pip3 install ansible==7.1.0

# Clean up
echo "Cleaning up..."
sudo apt-get autoremove -y
sudo apt-get clean
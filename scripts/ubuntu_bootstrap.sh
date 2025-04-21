#!/bin/bash

# Set strict mode
set -euo pipefail

echo "Disabling needrestart to prevent service blocking..."
echo "NEEDRESTART_MODE=a" | sudo tee /etc/needrestart/needrestart.conf

# Update system packages
echo "Updating system..."
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# Install dependencies
echo "Installing Python and Ansible..."
sudo apt-get install -y python3 python3-pip python3-venv git ansible

# Clean up
echo "Cleaning up..."
sudo apt-get autoremove -y
sudo apt-get clean

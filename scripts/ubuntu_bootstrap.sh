#!/bin/bash
set -euo pipefail

# Set needrestart to fully disable prompts
echo 'NEEDRESTART_MODE="a"' | sudo tee /etc/needrestart/needrestart.conf

# Force non-interactive mode
export DEBIAN_FRONTEND=noninteractive

echo "Updating system..."
sudo apt-get update -y
sudo apt-get upgrade -y

echo "Installing dependencies..."
sudo apt-get install -y python3 python3-pip python3-venv git ansible

echo "Cleaning up..."
sudo apt-get autoremove -y
sudo apt-get clean

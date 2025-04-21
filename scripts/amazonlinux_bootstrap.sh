#!/bin/bash

# Set strict mode
set -euo pipefail

echo "Updating system..."
sudo dnf update -y

echo "Installing Ansible..."
sudo dnf install -y ansible-core

echo "Bootstrap complete."

echo "Installing CloudWatch Agent..."
sudo dnf install -y amazon-cloudwatch-agent

echo "Installing SSM Agent..."
sudo dnf install -y amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

# Ensure services are running
echo "Verifying installed services..."
systemctl status amazon-cloudwatch-agent || echo "CloudWatch Agent might not be running"
systemctl status amazon-ssm-agent || echo "SSM Agent might not be running"

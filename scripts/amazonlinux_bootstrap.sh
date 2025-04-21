#!/bin/bash
set -euo pipefail

echo "Updating system..."
sudo dnf update -y

echo "Installing Ansible..."
sudo dnf install -y ansible-core

echo "Installing CloudWatch Agent..."
sudo dnf install -y amazon-cloudwatch-agent

echo "Installing SSM Agent..."
sudo dnf install -y amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

echo "Installing cronie (for automatic security updates)..."
sudo dnf install -y cronie
sudo systemctl enable crond
sudo systemctl start crond

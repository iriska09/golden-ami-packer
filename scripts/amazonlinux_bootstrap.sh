#!/bin/bash
set -euo pipefail

echo "Updating system..."
sudo dnf update -y

echo "Installing essential packages..."
sudo dnf install -y ansible-core amazon-cloudwatch-agent amazon-ssm-agent cronie fail2ban

echo "Configuring services..."
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

sudo systemctl enable crond
sudo systemctl start crond

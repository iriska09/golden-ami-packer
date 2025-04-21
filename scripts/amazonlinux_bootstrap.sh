#!/bin/bash
set -euo pipefail

echo "Updating system..."
sudo dnf upgrade --releasever=2023.7.20250414 -y  # 🚀 Ensures latest packages for AL2023

echo "Installing essential packages..."
sudo dnf install -y python3 python3-pip ansible amazon-cloudwatch-agent amazon-ssm-agent cronie fail2ban

echo "Configuring services..."
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

sudo systemctl enable crond
sudo systemctl start crond

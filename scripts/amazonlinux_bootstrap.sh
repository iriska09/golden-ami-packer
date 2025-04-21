#!/bin/bash
set -euo pipefail

echo "Updating system..."
sudo dnf5 update -y

echo "Installing essential packages..."
sudo dnf5 install -y \
    python3-libdnf5 \
    ansible-core \
    amazon-cloudwatch-agent \
    amazon-ssm-agent \
    cronie \
    fail2ban \
    audit

echo "Configuring services..."
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent
sudo systemctl enable crond
sudo systemctl start crond
sudo systemctl enable auditd
sudo systemctl start auditd

echo "Cleaning up..."
sudo dnf5 clean all
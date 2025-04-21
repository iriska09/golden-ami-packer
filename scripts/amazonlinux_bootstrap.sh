#!/bin/bash
set -euo pipefail

# System updates
sudo dnf5 update -y

# Install packages
sudo dnf5 install -y \
    python3 \
    ansible-core \
    amazon-cloudwatch-agent \
    amazon-ssm-agent \
    cronie \
    fail2ban \
    audit

# Enable services
sudo systemctl enable --now amazon-ssm-agent crond auditd
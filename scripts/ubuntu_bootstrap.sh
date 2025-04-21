#!/bin/bash
set -euo pipefail

# System updates
sudo dnf update -y

# Install required packages
sudo dnf install -y \
    python3 \
    ansible-core \
    amazon-cloudwatch-agent \
    amazon-ssm-agent \
    cronie \
    fail2ban \
    audit

# Configure services
sudo systemctl enable --now amazon-ssm-agent crond auditd

# Cleanup
sudo dnf clean all
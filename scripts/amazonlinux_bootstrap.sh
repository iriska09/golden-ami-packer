#!/bin/bash
set -euo pipefail

# Update system first
sudo dnf update -y

# Install required packages (using standard dnf, not dnf5)
sudo dnf install -y \
    python3-dnf \
    ansible-core \
    amazon-cloudwatch-agent \
    amazon-ssm-agent \
    cronie \
    fail2ban \
    audit

# Configure essential services
sudo systemctl enable --now amazon-ssm-agent crond auditd

# Cleanup
sudo dnf clean all
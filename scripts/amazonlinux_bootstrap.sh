#!/bin/bash
set -euo pipefail

# First determine available package manager
if command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
elif command -v yum &> /dev/null; then
    PKG_MANAGER="yum"
else
    echo "No supported package manager found!"
    exit 1
fi

# System updates
sudo $PKG_MANAGER update -y

# Install required packages
sudo $PKG_MANAGER install -y \
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
sudo $PKG_MANAGER clean all
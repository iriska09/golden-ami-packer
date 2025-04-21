#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections

echo "Updating system..."
sudo apt-get update -y
sudo apt-get upgrade -y

echo "Installing essential packages..."
sudo apt-get install -y \
  -o DPkg::Options::="--force-confdef" \
  -o DPkg::Options::="--force-confold" \
  python3 python3-pip python3-venv git ansible

# 🚀 **Fix: Removed needrestart completely**
sudo apt-get purge -y needrestart

echo "Installing Packer..."
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update
sudo apt-get install -y packer

echo "Cleaning up..."
sudo apt-get autoremove -y
sudo apt-get clean


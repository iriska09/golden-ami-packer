#!/bin/bash
set -euo pipefail

echo 'NEEDRESTART_MODE="a"' | sudo tee /etc/needrestart/needrestart.conf

export DEBIAN_FRONTEND=noninteractive


echo "Updating system..."
sudo apt-get update -y
sudo apt-get upgrade -y

echo "Installing essential packages..."
sudo apt-get install -y -o DPkg::Options::="--force-confdef" -o DPkg::Options::="--force-confold" python3 python3-pip python3-venv git ansible


echo "Cleaning up..."
sudo apt-get autoremove -y
sudo apt-get clean

PACKER_LOG=1 packer build -debug -var-file="../variables/ubuntu.pkrvars.hcl" ubuntu.pkr.hcl

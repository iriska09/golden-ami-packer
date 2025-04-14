#!/bin/bash
set -e

echo "Bootstrapping base image..."
sudo yum update -y || sudo apt update -y
sudo yum install -y python3 || sudo apt install -y python3

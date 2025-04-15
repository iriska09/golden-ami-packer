#!/bin/bash

# Install Ansible
sudo yum install -y ansible # For Amazon Linux
# sudo apt-get install -y ansible # Uncomment for Ubuntu if needed

# Install pip (Python package manager) for Ansible dependencies
sudo yum install -y python3-pip
pip3 install --upgrade pip
pip3 install ansible

# Run the Ansible playbook for AMI hardening
ansible-playbook /tmp/playbook.yml

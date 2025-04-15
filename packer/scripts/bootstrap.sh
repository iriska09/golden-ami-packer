# #!/bin/bash

# # Install Ansible
# sudo yum install -y ansible # For Amazon Linux
# # sudo apt-get install -y ansible # Uncomment for Ubuntu if needed

# # Install pip (Python package manager) for Ansible dependencies
# sudo yum install -y python3-pip
# pip3 install --upgrade pip
# pip3 install ansible

# # Run the Ansible playbook for AMI hardening
# ansible-playbook /tmp/playbook.yml
#!/bin/bash
# Install Ansible prerequisites
set -e

echo "Running bootstrap script..."

# OS detection
if [ -f /etc/redhat-release ]; then
    # Amazon Linux/CentOS/RHEL
    sudo yum update -y
    sudo yum install -y python3 python3-pip
elif [ -f /etc/lsb-release ]; then
    # Ubuntu
    sudo apt-get update -y
    sudo apt-get install -y python3 python3-pip
else
    echo "Unsupported OS"
    exit 1
fi

# Install Ansible
sudo pip3 install ansible

echo "Bootstrap completed successfully"
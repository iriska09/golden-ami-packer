# AMI Hardening Project

This project automates the creation of hardened Amazon Machine Images (AMIs) for Ubuntu and Amazon Linux using Packer, Ansible, and GitHub Actions.

## Features

- CIS Level 1 hardening for Ubuntu and Amazon Linux
- Automated security updates
- SSH hardening
- Firewall configuration (UFW for Ubuntu)
- Auditd configuration
- Security banner setup
- GitHub Actions pipeline with OIDC authentication

## Prerequisites

1. AWS Account with proper IAM permissions
2. GitHub repository
3. AWS OIDC provider configured in your AWS account

## Setup

1. Create an IAM role named `PackerInstanceProfile` with EC2 permissions
2. Configure GitHub OIDC provider in AWS IAM
3. Set up the following GitHub secrets:
   - `AWS_ACCOUNT_ID`: Your AWS account ID

## Usage

1. Navigate to GitHub Actions
2. Select "Build Hardened AMI" workflow
3. Click "Run workflow"
4. Select OS type (ubuntu or amazonlinux)
5. Specify AWS region (default: us-east-1)
6. Specify IAM role name (default: PackerInstanceProfile)
7. Click "Run workflow"

The hardened AMI will be created in your AWS account with a name like:
- `hardened-ubuntu-<timestamp>` for Ubuntu
- `hardened-amazonlinux-<timestamp>` for Amazon Linux

## Customization

You can modify the hardening rules by editing the Ansible playbooks:
- `ansible/ubuntu_playbook.yml` for Ubuntu
- `ansible/amazonlinux_playbook.yml` for Amazon Linux

## Security Notes

- All connections use temporary credentials via OIDC
- No long-term AWS credentials are stored
- IAM roles follow principle of least privilege
# Golden AMI Builder

This repo builds hardened AMIs (Amazon Linux and Ubuntu) using:
- Packer
- Ansible (CIS-level hardening)
- GitHub Actions with OIDC (no long-lived keys)

### Usage
- Trigger `build-ami-caller.yml` manually.
- Choose the image type: `amazon` or `ubuntu`.

### Secrets Required
- AWS_ROLE_ARN
- AWS_REGION
- AWS_SUBNET_ID
- AWS_IAM_INSTANCE_PROFILE
- AWS_SOURCE_AMAZON_AMI
- AWS_SOURCE_UBUNTU_AMI

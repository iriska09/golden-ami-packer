packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.0"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "source_ami" {
  type        = string
  description = "Source AMI ID"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for temporary instance"
}

variable "iam_instance_profile" {
  type        = string
  description = "IAM instance profile name"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

source "amazon-ebs" "amazon-linux" {
  ami_name              = "golden-amazon-linux-{{timestamp}}"
  ami_description       = "CIS Hardened Amazon Linux"
  source_ami            = var.source_ami
  instance_type         = "t3.micro"
  region                = var.region
  ssh_username          = "ec2-user"
  subnet_id             = var.subnet_id
  iam_instance_profile  = var.iam_instance_profile
  temporary_key_pair_type = "ed25519"
  ssh_pty               = true

  launch_block_device_mappings {
    device_name           = "/dev/xvda"
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name        = "golden-amazon-linux"
    OS          = "Amazon Linux"
    ManagedBy   = "Packer"
    SourceAMI   = "{{ .SourceAMI }}"
    BuildDate   = "{{ timestamp }}"
  }
}

build {
  sources = ["source.amazon-ebs.amazon-linux"]

  provisioner "shell" {
    script          = "../scripts/bootstrap.sh"
    execute_command = "sudo -E -S sh '{{ .Path }}'"
  }

  provisioner "ansible" {
    playbook_file   = "../../ansible/playbooks/playbook.yml"
    galaxy_file     = "../../ansible/requirements.yml"
    extra_arguments = [
      "-e", "os_type=amazon-linux",
      "--scp-extra-args", "'-O'",
      "--ssh-extra-args", "-o IdentitiesOnly=yes"
    ]
    user            = "ec2-user"
    use_proxy       = false
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
    custom_data = {
      ami_id    = "{{ .BuildID }}"
      build_date = "{{ timestamp }}"
    }
  }
}
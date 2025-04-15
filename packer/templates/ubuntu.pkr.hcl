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

source "amazon-ebs" "ubuntu" {
  ami_name              = "golden-ubuntu-{{timestamp}}"
  ami_description       = "CIS Hardened Ubuntu"
  source_ami            = var.source_ami
  instance_type         = "t3.micro"
  region                = var.region
  ssh_username          = "ubuntu"
  subnet_id             = var.subnet_id
  iam_instance_profile  = var.iam_instance_profile
  ssh_pty               = true

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name        = "golden-ubuntu"
    OS          = "Ubuntu"
    ManagedBy   = "Packer"
  }
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    script          = "../scripts/bootstrap-ubuntu.sh"
    execute_command = "sudo -E -S sh '{{ .Path }}'"
  }

  provisioner "ansible" {
    playbook_file   = "../../ansible/playbooks/playbook.yml"
    extra_arguments = ["-e", "os_type=ubuntu"]
    user            = "ubuntu"
  }
}
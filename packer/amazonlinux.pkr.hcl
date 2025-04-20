packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "source_ami" {
  type    = string
  default = "ami-0b0dcb5067f052a63" # Amazon Linux 2
}

variable "iam_instance_profile" {
  type    = string
  default = "PackerInstanceProfile"
}

source "amazon-ebs" "amazonlinux" {
  ami_name      = "hardened-amazonlinux-{{timestamp}}"
  instance_type = "t3.micro"
  region        = var.region
  source_ami    = var.source_ami
  ssh_username  = "ec2-user"
  ami_regions   = [var.region]
  
  iam_instance_profile = var.iam_instance_profile
  
  tags = {
    Name        = "Hardened-AmazonLinux-AMI"
    OS_Version  = "Amazon Linux 2"
    Environment = "Production"
    ManagedBy   = "Packer"
  }
}

build {
  sources = ["source.amazon-ebs.amazonlinux"]

  provisioner "shell" {
    script = "../scripts/amazonlinux_bootstrap.sh"
  }

  provisioner "ansible-local" {
    playbook_file = "../ansible/amazonlinux_playbook.yml"
    galaxy_file   = "../ansible/requirements.yml"
  }

  post-processor "manifest" {
    output = "manifest-amazonlinux.json"
    strip_path = true
  }
}
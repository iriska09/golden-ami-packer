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
  default = "ami-0fc5d935ebf8bc3bc" # Ubuntu 22.04 LTS
}

variable "iam_instance_profile" {
  type    = string
  default = "PackerInstanceProfile"
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "hardened-ubuntu-{{timestamp}}"
  instance_type = "t3.micro"
  region        = var.region
  source_ami    = var.source_ami
  ssh_username  = "ubuntu"
  ami_regions   = [var.region]
  
  iam_instance_profile = var.iam_instance_profile
  
  tags = {
    Name        = "Hardened-Ubuntu-AMI"
    OS_Version  = "Ubuntu 22.04"
    Environment = "Production"
    ManagedBy   = "Packer"
  }
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    script = "../scripts/ubuntu_bootstrap.sh"
  }

  provisioner "ansible-local" {
    playbook_file = "../ansible/ubuntu_playbook.yml"
    galaxy_file   = "../ansible/requirements.yml"
  }

  post-processor "manifest" {
    output = "manifest-ubuntu.json"
    strip_path = true
  }
}
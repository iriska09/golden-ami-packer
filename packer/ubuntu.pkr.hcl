packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "source_ami" {}
variable "subnet_id" {}
variable "iam_instance_profile" {}
variable "region" {}

source "amazon-ebs" "ubuntu" {
  region                      = var.region
  source_ami                  = var.source_ami
  instance_type               = "t3.micro"
  subnet_id                   = var.subnet_id
  iam_instance_profile        = var.iam_instance_profile
  ssh_username                = "ubuntu"
  associate_public_ip_address = true
  ami_name                    = "golden-ubuntu-{{timestamp}}"
}

build {
  name    = "ubuntu"
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "ansible" {
    playbook_file = "../ansible/playbook.yml"
  }
}

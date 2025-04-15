packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "source_ami" {}
variable "subnet_id" {}
variable "iam_instance_profile" {}
variable "region" {}

source "amazon-ebs" "ubuntu" {
  region                  = var.region
  source_ami              = var.source_ami
  subnet_id               = var.subnet_id
  instance_type           = "t3.micro"
  ssh_username            = "ubuntu"
  ami_name                = "golden-ubuntu-{{timestamp}}"
  iam_instance_profile    = var.iam_instance_profile
  associate_public_ip_address = true
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    script = "scripts/bootstrap.sh"
  }

  provisioner "ansible" {
    playbook_file = "../ansible/playbook.yml"
  }
}

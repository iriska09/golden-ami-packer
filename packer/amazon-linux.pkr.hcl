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

source "amazon-ebs" "amazon-linux" {
  region                  = var.region
  source_ami              = var.source_ami
  instance_type           = "t3.micro"
  subnet_id               = var.subnet_id
  iam_instance_profile    = var.iam_instance_profile
  ssh_username            = "ec2-user"
  associate_public_ip_address = true
  ami_name                = "golden-amazon-{{timestamp}}"
}

build {
  name = "amazon-linux"
  sources = ["source.amazon-ebs.amazon-linux"]

  provisioner "ansible" {
    playbook_file = "../ansible/playbook.yml"
  }
}

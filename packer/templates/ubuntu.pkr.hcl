# Add this at the top of your template files
packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

# Include variables
variable "source_ami" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "iam_instance_profile" {
  type = string
}

variable "region" {
  type    = string
  default = "us-east-1"
}

source "amazon-ebs" "ubuntu" {
  ami_name        = "golden-ubuntu-{{timestamp}}"
  source_ami      = var.source_ami
  instance_type   = "t3.micro"
  region          = var.region
  ssh_username    = "ubuntu"
  subnet_id       = var.subnet_id
  iam_instance_profile = var.iam_instance_profile

  launch_block_device_mappings {
    device_name = "/dev/sda1"
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
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
    script = "../scripts/bootstrap.sh"
  }

  provisioner "ansible" {
    playbook_file = "../../ansible/playbooks/playbook.yml"
    extra_arguments = ["-e", "os_type=ubuntu"]
  }
}
packer {
  required_plugins {
    amazon-ebs = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}


source "amazon-ebs" "ubuntu" {
  ami_name      = "hardened-ubuntu-{{timestamp}}"
  instance_type = "t3.micro"
  region        = "us-east-1"
  source_ami    = "ami-084568db4383264d4"
  ssh_username  = "ubuntu"

  vpc_id        = "vpc-0e383fe0b57adbffa" # Replace with your actual VPC ID
  subnet_id     = "subnet-076188052652f6332" # Replace with your actual Subnet ID

  tags = {
    Name = "Hardened-Ubuntu"
  }
}


build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    script = "../scripts/ubuntu_bootstrap.sh"
  }

  # 🚀 **Fix: Changed Ansible execution method to local**
  provisioner "ansible" {
    playbook_file = "../ansible/ubuntu_playbook.yml"
    user          = "ubuntu"
    inventory_file = "localhost,"
    extra_arguments = ["--connection=local", "--verbose"]
  }
}

packer {
  required_plugins {
    amazon = { source = "github.com/hashicorp/amazon", version = "~> 1" }
    ansible = { source = "github.com/hashicorp/ansible", version = "~> 1" }
  }
}
# ... [rest of your existing config] ...


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
    extra_arguments = ["-e", "os_type=amazon-linux"]
    user            = "ec2-user"
  }
}
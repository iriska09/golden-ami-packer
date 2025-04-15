# source "amazon-ebs" "amazon-linux" {
#   ami_name        = "golden-amazon-linux-{{timestamp}}"
#   source_ami      = var.source_ami
#   instance_type   = "t3.micro"
#   region          = var.region
#   ssh_username    = "ec2-user"
#   subnet_id       = var.subnet_id
#   iam_instance_profile = var.iam_instance_profile

#   launch_block_device_mappings {
#     device_name = "/dev/xvda"
#     volume_size = 20
#     volume_type = "gp3"
#     encrypted   = true
#   }

#   tags = {
#     Name = "golden-amazon-linux"
#     OS   = "Amazon Linux"
#   }
# }

# build {
#   sources = ["source.amazon-ebs.amazon-linux"]

#   provisioner "shell" {
#     script = "../scripts/bootstrap.sh"
#   }

#   provisioner "ansible" {
#     playbook_file = "../../ansible/playbooks/playbook.yml"
#     extra_arguments = ["-e", "os_type=amazon-linux"]
#   }
# }

source "amazon-ebs" "amazon-linux" {
  ami_name        = "golden-amazon-linux-{{timestamp}}"
  source_ami      = var.source_ami      # Uses declared variable
  instance_type   = "t3.micro"
  region          = var.region          # Uses declared variable
  subnet_id       = var.subnet_id       # Uses declared variable
  iam_instance_profile = var.iam_instance_profile  # Uses declared variable
}

  launch_block_device_mappings {
    device_name = "/dev/xvda"
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name        = "golden-amazon-linux"
    OS          = "Amazon Linux"
    Environment = var.environment
    ManagedBy   = "packer"
  }
}

build {
  sources = ["source.amazon-ebs.amazon-linux"]

  provisioner "shell" {
    script = "../scripts/bootstrap.sh"
  }

  provisioner "ansible" {
    playbook_file   = "../../ansible/playbooks/playbook.yml"
    galaxy_file     = "../../ansible/requirements.yml"
    extra_arguments = [
      "-e", "os_type=amazon-linux",
      "-e", "environment=${var.environment}"
    ]
    user            = "ec2-user"
  }

  post-processor "manifest" {
    output = "manifest.json"
  }
}
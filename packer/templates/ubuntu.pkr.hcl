# source "amazon-ebs" "ubuntu" {
#   ami_name        = "golden-ubuntu-{{timestamp}}"
#   source_ami      = var.source_ami
#   instance_type   = "t3.micro"
#   region          = var.region
#   ssh_username    = "ubuntu"
#   subnet_id       = var.subnet_id
#   iam_instance_profile = var.iam_instance_profile

#   launch_block_device_mappings {
#     device_name = "/dev/sda1"
#     volume_size = 20
#     volume_type = "gp3"
#     encrypted   = true
#   }

#   tags = {
#     Name = "golden-ubuntu"
#     OS   = "Ubuntu"
#   }
# }

# build {
#   sources = ["source.amazon-ebs.ubuntu"]

#   provisioner "shell" {
#     script = "../scripts/bootstrap.sh"
#   }

#   provisioner "ansible" {
#     playbook_file = "../../ansible/playbooks/playbook.yml"
#     extra_arguments = ["-e", "os_type=ubuntu"]
#   }
# }
source "amazon-ebs" "ubuntu" {
  ami_name        = "golden-ubuntu-{{timestamp}}"
  source_ami      = var.source_ami      # Uses declared variable
  instance_type   = "t3.micro"
  region          = var.region          # Uses declared variable
  subnet_id       = var.subnet_id       # Uses declared variable
  iam_instance_profile = var.iam_instance_profile  # Uses declared variable
.
}

  launch_block_device_mappings {
    device_name = "/dev/sda1"
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name        = "golden-ubuntu"
    OS          = "Ubuntu"
    Environment = var.environment
    ManagedBy   = "packer"
  }
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    script = "../scripts/bootstrap.sh"
  }

  provisioner "ansible" {
    playbook_file   = "../../ansible/playbooks/playbook.yml"
    galaxy_file     = "../../ansible/requirements.yml"
    extra_arguments = [
      "-e", "os_type=ubuntu",
      "-e", "environment=${var.environment}"
    ]
    user            = "ubuntu"
  }

  post-processor "manifest" {
    output = "manifest.json"
  }
}
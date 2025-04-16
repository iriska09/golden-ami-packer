packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1.3"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1.1"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name              = "golden-ubuntu-{{timestamp}}"
  ami_description       = "CIS Hardened Ubuntu"
  source_ami            = var.source_ami
  instance_type         = "t3.micro"
  region                = var.region
  ssh_username          = "ubuntu"
  subnet_id             = var.subnet_id
  iam_instance_profile  = var.iam_instance_profile
  ssh_pty               = true
  temporary_key_pair_type = "ed25519"

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name        = "golden-ubuntu"
    OS          = "Ubuntu"
    ManagedBy   = "Packer"
    SourceAMI   = "{{ .SourceAMI }}"
    BuildDate   = "{{ timestamp }}"
  }
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    script          = var.script_path
    execute_command = "sudo -E -S sh '{{ .Path }}'"
  }

  provisioner "ansible" {
    playbook_file   = var.playbook_path
    galaxy_file     = "../ansible/requirements.yml"
    extra_arguments = ["-e", "os_type=ubuntu"]
    user            = "ubuntu"
    use_proxy       = false
  }
}
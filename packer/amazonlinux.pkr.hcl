source "amazon-ebs" "amazonlinux" {
  ami_name        = "hardened-amazonlinux-{{timestamp}}"
  instance_type   = "t2.micro"
  region          = "us-east-1"
  source_ami      = "ami-0f88e80871fd81e91"  
  ssh_username    = "ec2-user"
  iam_instance_profile = "PackerInstanceProfile"

  vpc_id          = "vpc-0e383fe0b57adbffa"
  subnet_id       = "subnet-076188052652f6332"

  launch_block_device_mappings {
    device_name = "/dev/xvda"
    volume_size = 8
    volume_type = "gp3"
    delete_on_termination = true
  }
}

build {
  sources = ["source.amazon-ebs.amazonlinux"]

  provisioner "shell" {
    script = "../scripts/amazonlinux_bootstrap.sh"
    execute_command = "sudo -E bash '{{ .Path }}'"
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
  }


  provisioner "ansible" {
    playbook_file = "../ansible/amazonlinux_playbook.yml"
    user         = "ec2-user"
    inventory_file = "localhost,"
    extra_arguments = [
      "--connection=local",
      "-e", "ansible_python_interpreter=/usr/bin/python3",
      "-e", "ansible_pkg_mgr=dnf" , "-u", "ec2-user" 
    ]
  }
}
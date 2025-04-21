source "amazon-ebs" "ubuntu" {
  ami_name      = "hardened-ubuntu-{{timestamp}}"
  instance_type = "t3.micro"
  region        = "us-east-1"
  source_ami    = "ami-084568db4383264d4"
  ssh_username  = "ubuntu"
  
  tags = {
    Name = "Hardened-Ubuntu"
  }
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    script = "../scripts/ubuntu_bootstrap.sh"
  }

  provisioner "ansible-local" {
    playbook_file = "../ansible/ubuntu_playbook.yml"
  }
}
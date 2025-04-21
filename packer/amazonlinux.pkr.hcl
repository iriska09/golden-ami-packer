source "amazon-ebs" "amazonlinux" {
  ami_name      = "hardened-amazonlinux-{{timestamp}}"
  instance_type = "t3.micro"
  region        = "us-east-1"
  source_ami    = "ami-05f417c208be02d4d"  
  ssh_username  = "ec2-user"
  
  tags = {
    Name = "Hardened-AmazonLinux"
  }
}

build {
  sources = ["source.amazon-ebs.amazonlinux"]

  provisioner "shell" {
    script = "../scripts/amazonlinux_bootstrap.sh"
  }

  provisioner "ansible-local" {
    playbook_file = "../ansible/amazonlinux_playbook.yml"
  }
}
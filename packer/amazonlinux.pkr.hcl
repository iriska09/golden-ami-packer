source "amazon-ebs" "amazonlinux" {
  ami_name      = "hardened-amazonlinux-{{timestamp}}"
  instance_type = "t4g.micro"
  region        = "us-east-1"
  source_ami    = "ami-05f417c208be02d4d"  
  ssh_username  = "ec2-user"

  vpc_id        = "vpc-0e383fe0b57adbffa"  # Replace with your actual VPC ID
  subnet_id     = "subnet-076188052652f6332"  # Replace with your actual Subnet ID

  tags = {
    Name = "Hardened-AmazonLinux"
  }
}

build {
  sources = ["source.amazon-ebs.amazonlinux"]

  provisioner "shell" {
    script = "../scripts/amazonlinux_bootstrap.sh"
  }

  provisioner "ansible" {
    playbook_file = "../ansible/amazonlinux_playbook.yml"
    user          = "ec2-user"
    inventory_file = "localhost,"
    extra_arguments = ["--connection=local", "--verbose", "-vvv"]  # 🚀 Enable full debug logging
  }

}
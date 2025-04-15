variable "region" {}
variable "source_ami" {}
variable "ssh_username" {}
variable "iam_instance_profile" {}
variable "subnet_id" {}
variable "base_os" {}

source "amazon-ebs.ubuntu" "ubuntu" {
  region                  = var.region
  source_ami              = var.source_ami
  instance_type           = "t3.micro"
  ssh_username            = var.ssh_username
  iam_instance_profile    = var.iam_instance_profile
  subnet_id               = var.subnet_id
  associate_public_ip_address = true
  ami_name                = "golden-ami-${var.base_os}-${timestamp()}"
}

build {
  name = "ubuntu"
  sources = ["source.amazon-ebs.ubuntu.ubuntu"]

  provisioner "shell" {
    script = "scripts/bootstrap.sh"
  }

  provisioner "ansible" {
    playbook_file = "../ansible/playbook.yml"
  }
}
source "amazon-ebs" "ubuntu" {
  ami_name          = "ubuntu-{{timestamp}}"
  instance_type     = "t2.micro"
  region            = var.region
  subnet_id         = var.subnet_id
  source_ami        = var.source_ami
  iam_instance_profile = var.iam_instance_profile
  associate_public_ip_address = true

  # Provisioner to run the bootstrap script for Ansible hardening
  provisioner "file" {
    source      = "scripts/bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "/tmp/bootstrap.sh"
    ]
  }
}

build {
  sources = ["source.amazon-ebs.ubuntu"]
}

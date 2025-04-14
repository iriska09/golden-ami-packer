variable "source_ami" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "iam_instance_profile" {
  type = string
}

variable "region" {
  default = "us-east-1"
}

variable "subnet_id" {
  description = "The subnet ID for the EC2 instance."
  type        = string
}

variable "iam_instance_profile" {
  description = "IAM instance profile for the EC2 instance."
  type        = string
}

variable "source_ami" {
  description = "The source AMI to base the new AMI on."
  type        = string
}

variable "region" {
  description = "The AWS region."
  type        = string
}

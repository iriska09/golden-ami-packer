variable "source_ami" {
  type        = string
  description = "Source AMI ID"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for temporary instance"
}

variable "iam_instance_profile" {
  type        = string
  description = "IAM instance profile name"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}
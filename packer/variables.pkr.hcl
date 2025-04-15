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

required_plugins {
  amazon = {
    source  = "github.com/hashicorp/amazon"
    version = "~> 1.3" # More flexible version constraint
  }
  ansible = {
    source  = "github.com/hashicorp/ansible"
    version = "~> 1.1" # More flexible version constraint
  }
}
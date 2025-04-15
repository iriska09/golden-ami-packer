# variable "region" {
#   type = string
# }

# variable "source_ami" {
#   type = string
# }

# variable "ssh_username" {
#   type = string
# }

# variable "iam_instance_profile" {
#   type = string
# }

# variable "subnet_id" {
#   type = string
# }

# variable "base_os" {
#   type = string
# }
variable "source_ami" {
  type        = string
  description = "Source AMI ID"
}

variable "subnet_id" {
  type        = string
  description = "Subnet for temporary instance"
}

variable "iam_instance_profile" {
  type        = string
  description = "IAM instance profile for Packer"
}

variable "region" {
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Deployment environment (dev/prod)"
}

packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.0"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}
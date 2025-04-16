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

variable "script_path" {
  type        = string
  description = "Path to bootstrap script"
  default     = "./scripts/bootstrap.sh"  # Changed from ${path.root} version
}

variable "playbook_path" {
  type        = string
  description = "Path to Ansible playbook"
  default     = "../ansible/playbooks/cis-hardening.yml"  # Changed from ${path.root} version
}
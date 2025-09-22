# Variables for IBM Terraform & Vault Workshop
# Presenter: Mohamed Ramadan Issa

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "ibm-terraform-vault-workshop"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "workshop"
}

variable "presenter_name" {
  description = "Name of the workshop presenter"
  type        = string
  default     = "mohamed-ramadan-issa"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
  default     = 2
}

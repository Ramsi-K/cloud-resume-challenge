# Input Variables for Backend Infrastructure

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "ramsi_admin_access"
}

variable "project_name" {
  description = "Name of the project (used for resource naming)"
  type        = string
  default     = "cloud-resume-challenge"
}

variable "domain_name" {
  description = "Domain name for the website"
  type        = string
  default     = "ramsi.dev"
}
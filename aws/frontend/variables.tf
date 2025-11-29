# Input Variables for AWS Frontend Infrastructure

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

variable "domain_name" {
  description = "Domain name for the website (apex domain)"
  type        = string
  default     = "ramsi.dev"
}

variable "domain_name_www" {
  description = "WWW subdomain (will redirect to apex)"
  type        = string
  default     = "www.ramsi.dev"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "cloud-resume-challenge"
}

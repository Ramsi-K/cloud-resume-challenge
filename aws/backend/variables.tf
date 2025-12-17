# Input Variables for Backend Infrastructure

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
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
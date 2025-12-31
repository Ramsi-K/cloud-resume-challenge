variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "domain_name" {
  description = "Domain name for the website"
  type        = string
  default     = "ramsi.dev"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "cloudresume"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}
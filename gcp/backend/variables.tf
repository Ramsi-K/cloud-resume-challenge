variable "project_id" {
  description = "GCP project ID"
  type        = string
  default     = "cloud-resume-challenge-482812"
}

variable "region" {
  description = "GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "domain_name" {
  description = "Domain name for the website"
  type        = string
  default     = "ramsi.dev"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "cloud-resume-challenge"
}

variable "common_tags" {
  description = "Common labels for all resources"
  type        = map(string)
  default = {
    project     = "cloud-resume-challenge"
    environment = "production"
    managed_by  = "terraform"
  }
}
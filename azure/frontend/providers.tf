# Terraform Backend Configuration
terraform {
  required_version = ">= 1.7"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Azure Provider Configuration - Uses Azure CLI authentication
provider "azurerm" {
  features {}
  # Will use your current Azure CLI login automatically
}
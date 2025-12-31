# Generate random suffix for globally unique storage account name
resource "random_string" "storage_suffix" {
  length  = 6
  lower   = true
  numeric = true
  special = false
  upper   = false
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${var.project_name}-rg"
  location = var.location

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Storage Account for Static Website
resource "azurerm_storage_account" "website" {
  name                     = "${replace(var.project_name, "-", "")}${random_string.storage_suffix.result}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  static_website {
    index_document     = "index.html"
    error_404_document = "404.html"
  }

  tags = {
    Name        = "Resume Website Storage"
    Project     = var.project_name
    Environment = var.environment
  }
}

# Azure CDN Profile (Standard Verizon - works with free/student accounts)
resource "azurerm_cdn_profile" "website" {
  name                = "${var.project_name}-cdn"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard_Verizon"

  tags = {
    Name        = "Resume Website CDN"
    Project     = var.project_name
    Environment = var.environment
  }
}

# CDN Endpoint
resource "azurerm_cdn_endpoint" "website" {
  name                = "${var.project_name}-endpoint"
  profile_name        = azurerm_cdn_profile.website.name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  origin {
    name      = "storage"
    host_name = azurerm_storage_account.website.primary_web_host
  }

  is_https_allowed = true
  is_http_allowed  = true

  # SPA routing rules for Verizon
  delivery_rule {
    name  = "SPArouting"
    order = 1

    url_path_condition {
      operator         = "BeginsWith"
      negate_condition = false
      match_values     = ["/blog", "/projects", "/resume"]
    }

    url_rewrite_action {
      source_pattern          = "/"
      destination             = "/index.html"
      preserve_unmatched_path = false
    }
  }

  tags = {
    Name        = "Resume Website CDN Endpoint"
    Project     = var.project_name
    Environment = var.environment
  }
}
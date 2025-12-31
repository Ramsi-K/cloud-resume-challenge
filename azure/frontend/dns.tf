# Azure DNS Zone
resource "azurerm_dns_zone" "main" {
  name                = var.domain_name
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    Name        = "Resume Website DNS Zone"
    Project     = var.project_name
    Environment = var.environment
  }
}

# CNAME record for www pointing to storage account
resource "azurerm_dns_cname_record" "www" {
  name                = "www"
  zone_name           = azurerm_dns_zone.main.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 3600
  record              = replace(replace(azurerm_storage_account.website.primary_web_endpoint, "https://", ""), "/", "")
}

# A record for apex domain (will be configured manually)
# Note: Azure Storage doesn't support apex domain directly, so we'll use CNAME for www only
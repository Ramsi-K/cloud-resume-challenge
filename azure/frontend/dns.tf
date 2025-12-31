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

# CNAME record for www pointing to Static Web App
resource "azurerm_dns_cname_record" "www" {
  name                = "www"
  zone_name           = azurerm_dns_zone.main.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 300
  record              = azurerm_static_web_app.website.default_host_name
}

# Custom domain for Static Web App
resource "azurerm_static_web_app_custom_domain" "website" {
  static_web_app_id = azurerm_static_web_app.website.id
  domain_name       = "www.${var.domain_name}"
  validation_type   = "cname-delegation"
}
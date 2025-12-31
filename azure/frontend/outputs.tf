output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.website.name
}

output "storage_website_endpoint" {
  description = "Storage account static website endpoint"
  value       = azurerm_storage_account.website.primary_web_endpoint
}

output "static_web_app_url" {
  description = "Static Web App default URL"
  value       = "https://${azurerm_static_web_app.website.default_host_name}"
}

output "static_web_app_name" {
  description = "Static Web App name"
  value       = azurerm_static_web_app.website.name
}

output "dns_zone_nameservers" {
  description = "DNS zone nameservers - Update these in Namecheap"
  value       = azurerm_dns_zone.main.name_servers
}

output "website_url" {
  description = "Website URL with CDN and custom domain"
  value       = "https://www.${var.domain_name}"
}
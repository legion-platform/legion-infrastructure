output "name" {
  value       = azurerm_resource_group.k8s.name
  description = "Name of created Azure resource group"
}

output "location" {
  value       = azurerm_resource_group.k8s.location
  description = "Location in which Azure resource group have been created"
}
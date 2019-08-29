output "subnet_id" {
  value       = azurerm_subnet.subnet.id
  description = "ID of created VPC subnet"
}

output "subnet_name" {
  value       = azurerm_subnet.subnet.name
  description = "Name of created VPC subnet"
}
output "private_ip" {
  value = azurerm_firewall.aks.ip_configuration[0].private_ip_address
}

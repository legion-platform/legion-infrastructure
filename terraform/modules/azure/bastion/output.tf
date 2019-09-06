output "private_ip" {
  value = azurerm_network_interface.aks_bastion_nic.private_ip_address
}

output "deploy_privkey" {
  value = tls_private_key.bastion_deploy.private_key_pem
}
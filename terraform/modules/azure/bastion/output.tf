output "bastion_ip" {
  value = "${var.bastion_ssh_user}@${azurerm_public_ip.aks_bastion_publicip.ip_address}"
}
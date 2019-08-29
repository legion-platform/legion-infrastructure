output "k8s_api_address" {
  value = azurerm_kubernetes_cluster.aks.kube_config.0.host
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
}

output "lb_ip_address" {
  value = azurerm_public_ip.ext_ip.ip_address
}
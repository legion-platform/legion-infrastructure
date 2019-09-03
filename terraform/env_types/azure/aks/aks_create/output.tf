output "bastion_connection_string" {
  value = module.aks_bastion_host.bastion_ip
}

output "k8s_api_address" {
  value = module.aks_cluster.k8s_api_address
}
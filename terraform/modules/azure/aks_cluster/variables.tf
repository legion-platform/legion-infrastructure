variable "secrets_storage" {
  description = "Name of S3 bucket with TLS artifacts"
}

variable "cluster_name" {
  description = "Legion k8s cluster name"
  default     = "legion"
}
variable "location" {
  description = "Azure location where the resource group should be created"
}

variable "resource_group" {
  description = "The name of the resource group, unique within Azure subscription"
  default     = "testResourceGroup1"
}

variable "k8s_version" {
  default     = "1.14.6"
  description = "Version of Kubernetes engine"
}

variable "ssh_user" {
  default     = "ubuntu"
  description = "Default ssh user"
}

variable "aks_dns_prefix" {
  description = "DNS prefix specified when creating the cluster"
  default     = "k8stest"
}

variable "aks_subnet_id" {
  description = "ID of subnet for the cluster nodes to run"
}

variable "aks_tags" {
  description = "Tags used for Azure Kubernetes cluster definition"
  default     = {}
  type        = "map"
}

variable "aks_analytics_workspace_id" {
  description = "Azure Log Analytics workspace ID"
}

variable "sp_id" {
  description = "Service Principal account ID"
}

variable "sp_secret" {
  description = "Service Principal account secret"
}

variable "node_machine_type" {
  default     = "Standard_B2s"
  description = "Machine type of cluster worker nodes (basic pool)"
}

variable "node_disk_size_gb" {
  default     = "20"
  description = "Persistent disk size for cluster worker nodes"
}

variable "node_machine_type_highcpu" {
  default     = "Standard_B4ms"
  description = "Machine type of cluster worker nodes (highcpu pool)"
}

variable "aks_num_nodes_min" {
  default     = "1"
  description = "Minimum number of nodes in first node pool"
}

variable "aks_num_nodes_max" {
  default     = "3"
  description = "Maximum number of nodes in first node pool"
}

variable "aks_highcpu_num_nodes_max" {
  default     = "2"
  description = "Maximum number of nodes in High CPU node pool"
}

variable "bastion_machine_type" {
  default = "Standard_B1ls"
}
variable "bastion_tags" {
  default     = {}
  description = "Bastion host tags"
  type        = "map"
}
variable "bastion_hostname" {
  default     = "bastion"
  description = "bastion hostname"
}
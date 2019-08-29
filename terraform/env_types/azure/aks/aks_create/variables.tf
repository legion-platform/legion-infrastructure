############################################################################################################

variable "azure_tenant_id" {
  description = "Azure Tenant ID"
}

variable "azure_subscription_id" {
  description = "Azure Subscription ID tied to the tenant"
}

variable "azure_client_id" {
  description = "Azure Service Principal account ID"
}

variable "azure_client_secret" {
  description = "Azure Service Principal account secret"
}

variable "azure_location" {
  description = "Azure location in which the resource group will be created"
  default     = "eastus"
}

variable "aws_profile" {
  description = "AWS profile name"
}

variable "aws_credentials_file" {
  description = "AWS credentials file location"
}

variable "aws_region" {
  description = "Region of AWS resources"
}

variable "secrets_storage" {
  description = "Name of S3 bucket with TLS artifacts"
}

############################################################################################################

variable "cluster_name" {
  description = "Legion k8s cluster name"
  default     = "legion"
}

variable "aks_common_tags" {
  description = "Set of common tags assigned to all cluster resources"
  type        = "map"
  default     = {
    environment = "Development"
    purpose     = "Kubernetes Cluster"
  }
}

variable "aks_dns_prefix" {
  description = "DNS prefix for Kubernetes cluster"
  default     = "k8stest"
}

variable "aks_cidr" {
  default = "10.255.0.0/24"  
}

variable "k8s_version" {
  description = "Kubernetes master version"
  default     = "1.13.10"
}

variable "allowed_ips" {
  description = "CIDR to allow access from"
}

#variable "agent_cidr" {
#  description = "Jenkins agent CIDR to allow access for CI jobs or your WAN address in case of locla run"
#}
#variable "dns_zone_name" {
#  description = "Cluster root DNS zone name"
#}

#############
# Node pool
#############
variable "node_disk_size_gb" {
  description = "Persistent disk size for cluster worker nodes"
}
variable "node_machine_type" {
  description = "Machine type of aks nodes"
}

variable "aks_num_nodes_min" {
  default = "1"
  description = "Number of nodes in each aks cluster zone"
}
variable "aks_num_nodes_max" {
  default = "5"
  description = "Number of nodes in each aks cluster zone"
}
variable "nodes_sa" {
  default = "default"
  description = "Service account for cluster nodes"
}

################
# Bastion host
################
variable "bastion_machine_type" {
  default = "f1-micro"
}
variable "bastion_tag" {
  default = ""
  description = "Bastion network tags"
}
variable "bastion_hostname" {
  default = "bastion"
  description = "bastion hpstname"
}
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

variable "azure_resource_group" {
  description = "Azure base resource group name"
  default     = "legion-rg"
}

############################################################################################################

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

variable "aks_analytics_workspace_id" {
  description = "Azure Log Analytics workspace ID"
  default     = "my-test-default-variable-eica0Chi"
}

variable "cluster_name" {
  description = "Legion k8s cluster name"
  default     = "legion"
}

variable "public_ip_name" {
  description = "Name of public IP-address used for AKS cluster"
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
  description = "Overall VPC address space for all subnets in it"
  default     = "10.255.255.0/24"
}

variable "k8s_version" {
  description = "Kubernetes master version"
  default     = "1.13.10"
}

variable "allowed_ips" {
  description = "CIDRs to allow access from"
}

#variable "agent_cidr" {
#  description = "Jenkins agent CIDR to allow access for CI jobs or your WAN address in case of locla run"
#}
#variable "dns_zone_name" {
#  description = "Cluster root DNS zone name"
#}

################
# Bastion host
################
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

################
# k8s node pools
################
variable "node_pools" {
  default = [
    {
      name               = "main"
      initial_node_count = "3"
      max_pods           = "64"
      autoscaling = {
        min_node_count = "1"
        max_node_count = "5"
      }
      node_config = {}
    },

  ]
}
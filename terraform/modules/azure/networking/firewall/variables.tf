variable "cluster_name" {
  description = "Legion cluster name"
  default     = "legion"
}

variable "location" {
  description = "Azure location of resource group"
}

variable "resource_group" {
  description = "Azure resource group name"
}

variable "aks_subnet_name" {
  description = "AKS worker nodes subnet name"
}

variable "aks_subnet_cidr" {
  description = "AKS worker nodes subnet range"
}

variable "fw_subnet_cidr" {
  description = "Firewall subnet address range"
}

variable "bastion_ip" {
  description = "Private IP of bastion host"
}

variable "public_ip_name" {
  description = "Name of public IP-address used for AKS cluster"
}

variable "vpc_name" {
  description = "Name of virtual network in which firewall subnet should be created"
}

variable "allowed_ips" {
  description = "CIDRs list to allow access from"
}

variable "tags" {
  description = "Tags used for virtual network"
  default     = {}
  type        = "map"
}
variable "cluster_name" {
  description = "Legion cluster name"
  default     = "legion"
}

variable "location" {
  description = "Azure location where the resource group is created"
}

variable "resource_group" {
  description = "Azure resource group name"
}

variable "subnet_cidr" {
  description = "VPC subnet range"
}

variable "tags" {
  description = "Tags used for virtual network"
  default     = {}
  type        = "map"
}
variable "project_id" {
  description = "Target project id"
}

variable "zone" {
  description = "Default zone"
}

variable "region" {
  description = "Region of resources"
}

variable "cluster_name" {
  default     = "legion"
  description = "Legion cluster name"
}

variable "network_name" {
  description = "VPC Netwrok name"
}

variable "allowed_ips" {
  description = "Subnet ranges to whitelist on cluster"
}

variable "bastion_tag" {
  description = "Bastion network tag"
}

variable "gke_node_tag" {
  description = "GKE cluster nodes tag"
}

variable "master_ipv4_cidr_block" {
  default     = "172.25.100.0/28"
  description = "GKE master CIDR"
}


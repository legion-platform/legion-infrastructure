############################################################################################################

variable "azure_resource_group" {
  description = "Azure base resource group name"
  default     = "legion-rg"
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
  default     = "legion"
  description = "Legion cluster name"
}

variable "public_ip_name" {
  description = "Name of public IP-address used for AKS cluster"
}

variable "tiller_image" {
  default = "gcr.io/kubernetes-helm/tiller:v2.14.0"
}

variable "legion_helm_repo" {
  description = "Legion helm repo"
}

variable "legion_infra_version" {
  description = "Legion infra release version"
}

variable "root_domain" {
  description = "Legion cluster root domain"
}

variable "docker_repo" {
  description = "Legion Docker repo url"
}

# variable "dns_zone_name" {
#   description = "Cluster root DNS zone name"
# }
# variable "network_name" {
#   description = "The VPC network to host the cluster in"
# }

variable "aks_cidr" {
  description = "VPC subnet range"
}

########################
# Prometheus monitoring
########################
# variable "allowed_ips" {
#   description = "CIDR to allow access from"
# }
variable "alert_slack_url" {
  description = "Alert slack usrl"
  default     = "https://localhost"
}

variable "grafana_admin" {
  description = "Grafana admion username"
}

variable "grafana_pass" {
  description = "Grafana admin password"
}

variable "grafana_storage_class" {
  default     = "standard"
  description = "Grafana storage class"
}

# variable "github_org_name" {
#   description = "Github Organization for dex authentication"
# }

variable "monitoring_namespace" {
  default     = "kube-monitoring"
  description = "clusterwide monitoring namespace"
}

##################
# OAuth2
##################
variable "oauth_client_id" {
  description = "OAuth2 Client ID"
}

variable "oauth_client_secret" {
  description = "OAuth2 Client Secret"
}

variable "oauth_cookie_secret" {
  description = "OAuth2 Cookie Secret"
}

variable "keycloak_realm" {
  description = "Keycloak realm"
}

variable "keycloak_url" {
  description = "Keycloak URL"
}

variable "keycloak_realm_audience" {
  description = "Keycloak real audience"
}

variable "oauth_scope" {
  description = "Scope for OAuth"
}

########################
# Istio
########################
variable "istio_namespace" {
  default     = "istio-system"
  description = "istio namespace"
}

variable "knative_namespace" {
  default     = "knative-serving"
  description = "Knative namespace"
}
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

############################################################################################################

variable "cluster_name" {
  description = "Legion k8s cluster name"
  default     = "legion"
}

variable "tiller_image" {
  default = "gcr.io/kubernetes-helm/tiller:v2.14.0"
}

variable "legion_helm_repo" {
  description = "Legion helm repo"
}

variable "istio_helm_repo" {
  description = "Istio helm repo"
}
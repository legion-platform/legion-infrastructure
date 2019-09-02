########################################################
# K8S Cluster Setup
########################################################

# Install TLS cert as a secret
resource "kubernetes_secret" "tls_default" {
  count = length(var.tls_namespaces)
  metadata {
    name      = "${var.cluster_name}-tls"
    namespace = element(var.tls_namespaces, count.index)
  }
  data = {
    "tls.key" = var.tls_key
    "tls.crt" = var.tls_crt
  }
  type = "kubernetes.io/tls"
}
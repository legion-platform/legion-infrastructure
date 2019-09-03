# Install Nginx Ingress using Helm Chart
resource "helm_release" "nginx-ingress" {
  name       = "nginx-ingress"
  repository = "stable"
  chart      = "nginx-ingress"
  namespace  = "kube-system"
  version    = "0.25.1"
  wait       = false
  
  set {
    name  = "controller.service.loadBalancerIP"
    value = var.lb_ip_address
  }
  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }
  set {
    name  = "controller.replicaCount"
    value = var.replicas
  }
}

# Enterprise sleep to ensure that load balacer has specific IP address
resource "null_resource" "lb_delay" {
  provisioner "local-exec" {
    command = "timeout 180 bash -c 'until kubectl get svc -n kube-system nginx-ingress-controller -o jsonpath=\"{.spec.loadBalancerIP}\" | grep \"${var.lb_ip_address}\"; do sleep 5; done'"
  }
  depends_on = [helm_release.nginx-ingress]
}
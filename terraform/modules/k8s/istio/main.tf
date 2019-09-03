provider "helm" {
  version         = "v0.10.0"
  install_tiller  = false
}

resource "kubernetes_namespace" "istio" {
  metadata {
    name = var.istio_namespace
  }
}

resource "kubernetes_secret" "tls_istio" {
  metadata {
    name      = "${var.cluster_name}-tls"
    namespace = var.istio_namespace
  }
  data = {
    "tls.key" = var.tls_secret_key
    "tls.crt" = var.tls_secret_crt
  }
  type       = "kubernetes.io/tls"
  depends_on = [kubernetes_namespace.istio]
}

resource "helm_release" "istio-init" {
  name        = "istio-init"
  chart       = "istio/istio-init"
  version     = var.istio_version
  namespace   = var.istio_namespace
  repository  = "istio"
}

resource "null_resource" "delay" {
  provisioner "local-exec" {
    command = "timeout 200 bash -c 'until [ $(kubectl get crds | grep \"istio.io\" | wc -l) -ge 23 ]; do sleep 5; done'"
  }
  depends_on = [helm_release.istio-init]
}

data "template_file" "istio_values" {
  template = file("${path.module}/templates/istio.yaml")
  vars = {
    cluster_name         = var.cluster_name
    root_domain          = var.root_domain
    monitoring_namespace = var.monitoring_namespace
  }
}

resource "helm_release" "istio" {
  name        = "istio"
  chart       = "istio/istio"
  version     = var.istio_version
  namespace   = var.istio_namespace
  repository  = "istio"

  values = [
    data.template_file.istio_values.rendered,
  ]

  depends_on = [null_resource.delay]
}

resource "kubernetes_namespace" "knative" {
  metadata {
    name = var.knative_namespace
    labels = {
      istio-injection = "enabled"
    }
  }
}

resource "kubernetes_secret" "tls_knative" {
  metadata {
    name      = "${var.cluster_name}-tls"
    namespace = var.knative_namespace
  }
  data = {
    "tls.key" = var.tls_secret_key
    "tls.crt" = var.tls_secret_crt
  }
  type       = "kubernetes.io/tls"
  depends_on = [kubernetes_namespace.knative]
}

resource "helm_release" "knative" {
  name          = "knative"
  chart         = "knative"
  version       = var.legion_infra_version
  namespace     = var.knative_namespace
  repository    = "legion"
  depends_on = [kubernetes_namespace.knative, helm_release.istio]
}

provider "helm" {
  version         = "v0.9.1"
  install_tiller  = false
}

data "helm_repository" "legion" {
    name = "legion_github"
    url  = "${var.legion_helm_repo}"
}

########################################################
# Prometheus monitoring
########################################################
resource "kubernetes_namespace" "monitoring" {
  metadata {
    annotations {
      name = "${var.monitoring_namespace}"
    }
    labels {
      project         = "legion"
      k8s-component   = "monitoring"
    }
    name = "${var.monitoring_namespace}"
  }
}

resource "kubernetes_secret" "tls_monitoring" {
  metadata {
    name        = "${var.cluster_name}-tls"
    namespace   = "${var.monitoring_namespace}"
  }
  data {
    "tls.key"   = "${var.tls_secret_key}"
    "tls.crt"   = "${var.tls_secret_crt}}"
  }
  type          = "kubernetes.io/tls"
  depends_on    = ["kubernetes_namespace.monitoring"]
}

data "template_file" "monitoring_values" {
  template = "${file("${path.module}/templates/monitoring.yaml")}"
  vars = {
    monitoring_namespace      = "${var.monitoring_namespace}"
    legion_infra_version      = "${var.legion_infra_version}"
    cluster_name              = "${var.cluster_name}"
    root_domain               = "${var.root_domain}"
    docker_repo               = "${var.docker_repo}"
    alert_slack_url           = "${var.alert_slack_url}"
    grafana_admin             = "${var.grafana_admin}"
    grafana_pass              = "${var.grafana_pass}"
    grafana_storage_class     = "${var.grafana_storage_class}"
  }
}

resource "helm_release" "monitoring" {
    name        = "monitoring"
    chart       = "monitoring"
    version     = "${var.legion_infra_version}"
    namespace   = "${var.monitoring_namespace}"
    repository  = "${data.helm_repository.legion.metadata.0.name}"

    values = [
      "${data.template_file.monitoring_values.rendered}"
    ]
    depends_on    = ["data.helm_repository.legion"]
}

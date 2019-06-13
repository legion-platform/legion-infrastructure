########################################################
# K8S setup
########################################################
module "k8s_setup" {
  source                    = "../../../modules/k8s"
  config_context_auth_info  = "${var.config_context_auth_info}"
  config_context_cluster    = "${var.config_context_cluster}"
  aws_profile               = "${var.aws_profile}"
  aws_credentials_file      = "${var.aws_credentials_file}"
  zone                      = "${var.zone}"
  region                    = "${var.region}"
  region_aws                = "${var.region_aws}"
  project_id                = "${var.project_id}"
  cluster_name              = "${var.cluster_name}"
  allowed_ips               = ["${var.allowed_ips}"]
  secrets_storage           = "${var.secrets_storage}"
  legion_helm_repo          = "${var.legion_helm_repo}"
  legion_infra_version      = "${var.legion_infra_version}"
  alert_slack_url           = "${var.alert_slack_url}"
  root_domain               = "${var.root_domain}"
  dns_zone_name             = "${var.dns_zone_name}"
  grafana_admin             = "${var.grafana_admin}"
  grafana_pass              = "${var.grafana_pass}"
  docker_repo               = "${var.docker_repo}"
  cluster_context           = "${var.cluster_context}"
  github_org_name           = "${var.github_org_name}"
  dex_github_clientid       = "${var.dex_github_clientid}"
  dex_github_clientSecret   = "${var.dex_github_clientSecret}"
  dex_client_secret         = "${var.dex_client_secret}"
  monitoring_namespace      = "${var.monitoring_namespace}"
  dex_static_user_email     = "${var.dex_static_user_email}"
  dex_static_user_pass      = "${var.dex_static_user_pass}"
  dex_static_user_hash      = "${var.dex_static_user_hash}"
  dex_static_user_name      = "${var.dex_static_user_name}"
  dex_static_user_id        = "${var.dex_static_user_id}"
  dex_client_id             = "${var.dex_client_id}"
  keycloak_client_secret    = "${var.keycloak_client_secret}"
  keycloak_client_id        = "${var.keycloak_client_id}"
  keycloak_admin_user       = "${var.keycloak_admin_user}"
  keycloak_admin_pass       = "${var.keycloak_admin_pass}"
  keycloak_db_user          = "${var.keycloak_db_user}"
  keycloak_db_pass          = "${var.keycloak_db_pass}"
  keycloak_pg_user          = "${var.keycloak_pg_user}"
  keycloak_pg_pass          = "${var.keycloak_pg_pass}"
  network_name              = "legion-test-vpc"
}

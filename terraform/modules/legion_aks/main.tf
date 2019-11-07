resource "random_string" "name" {
  count       = 2
  length      = 20
  upper       = false
  lower       = true
  number      = true
  min_numeric = 5
  special     = false
}

data "azurerm_public_ip" "egress" {
  name                = var.ip_egress_name
  resource_group_name = var.resource_group
}

data "azurerm_public_ip" "bastion" {
  name                = "${var.cluster_name}-bastion"
  resource_group_name = var.resource_group
}

locals {
  dockercfg = {
    "${azurerm_container_registry.legion.login_server}" = {
      email    = ""
      username = azurerm_container_registry.legion.admin_username
      password = azurerm_container_registry.legion.admin_password
    }
  }

  storage_tags = merge(
    { "purpose" = "Legion models storage" },
    var.tags
  )
  registry_tags = merge(
    { "purpose" = "Legion models images registry" },
    var.tags
  )

  model_docker_user        = azurerm_container_registry.legion.admin_username
  model_docker_password    = azurerm_container_registry.legion.admin_password
  model_docker_repo        = "${azurerm_container_registry.legion.login_server}/${var.cluster_name}"
  model_docker_web_ui_link = "https://${local.model_docker_repo}"

  sas_token_period = "168h" # - 7 days # 8760h - 1 year

  allowed_nets = concat(
    list(var.aks_subnet_cidr),
    list(var.service_cidr),
    list(data.azurerm_public_ip.egress.ip_address),
    list(data.azurerm_public_ip.bastion.ip_address),
    split(", ", replace(join(", ", var.allowed_ips), "/32", ""))
  )
}

########################################################
# Azure Container Registry
########################################################
resource "azurerm_container_registry" "legion" {
  name                     = random_string.name[0].result
  resource_group_name      = var.resource_group
  location                 = var.location
  sku                      = "Standard"
  admin_enabled            = true

  tags                     = local.registry_tags
}

resource "null_resource" "secure_kube_api" {
  triggers = {
    build_number = timestamp()
  }

  provisioner "local-exec" {
    interpreter = ["timeout", "300", "bash", "-c"]
    command = <<EOF
      if [ -z "$(az extension list | jq -r '.[] | select(.name == "aks-preview")')" ]; then
        az extension add -n aks-preview -y
      else
        az extension update -n aks-preview || true
      fi

      az aks update \
        --resource-group ${var.resource_group} \
        --name ${var.cluster_name} \
        --api-server-authorized-ip-ranges ${join(",", local.allowed_nets)}
    EOF
  }
  provisioner "local-exec" {
    when    = "destroy"
    interpreter = ["timeout", "300", "bash", "-c"]
    command = <<EOF
      if [ -z "$(az extension list | jq -r '.[] | select(.name == "aks-preview")')" ]; then
        az extension add -n aks-preview -y
      else
        az extension update -n aks-preview || true
      fi

      az aks update \
        --resource-group ${var.resource_group} \
        --name ${var.cluster_name} \
        --api-server-authorized-ip-ranges ""
    EOF
  }
}

########################################################
# Azure Blob container
########################################################
resource "azurerm_storage_account" "legion_data" {
  name                     = random_string.name[1].result
  resource_group_name      = var.resource_group
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action = "Allow"
    bypass         = [ "Logging", "Metrics", "AzureServices" ]
    ip_rules       = concat(
      # Removing /32 networks masks just in case
      # https://docs.microsoft.com/en-us/azure/storage/common/storage-network-security#grant-access-from-an-internet-ip-range
      split(", ", replace(join(", ", var.allowed_ips), "/32", "")),
      list(data.azurerm_public_ip.egress.ip_address),
      list(data.azurerm_public_ip.bastion.ip_address)
    )
  }

  tags       = local.storage_tags
  depends_on = [null_resource.secure_kube_api]
}

data "azurerm_storage_account_sas" "legion" {
  connection_string = azurerm_storage_account.legion_data.primary_connection_string
  https_only        = true

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  resource_types {
    service   = true
    container = true
    object    = true
  }

  start  = formatdate("YYYY-MM-DD", timestamp())
  expiry = formatdate("YYYY-MM-DD", timeadd(timestamp(), local.sas_token_period))

  permissions {
    read    = true
    write   = true
    delete  = false
    list    = true
    add     = true
    create  = true
    update  = true
    process = false
  }
}

resource "azurerm_storage_container" "legion_bucket" {
  name                  = var.legion_data_bucket
  storage_account_name  = azurerm_storage_account.legion_data.name
  container_access_type = "private"
  metadata              = local.storage_tags
  depends_on            = [azurerm_storage_account.legion_data]
}

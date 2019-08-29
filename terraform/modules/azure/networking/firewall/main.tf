data "http" "external_ip" {
  url = "http://ipv4.icanhazip.com"
}

locals {
  allowed_subnets = concat(list("${chomp(data.http.external_ip.body)}/32"), var.allowed_ips)
}


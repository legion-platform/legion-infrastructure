# We take the penultimate IP-address from the subnet, because the latter is used for broadcast
data "external" "last_ip" {
  program = ["python3", "-c", "import ipaddress; print('{\"ip\": \"'+str(ipaddress.IPv4Network('${var.cidr}')[-2])+'\"}')"]
}
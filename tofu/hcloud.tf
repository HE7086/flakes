provider "hcloud" {
  token = local.secrets.hetzner.token
}

locals {
  nodes = {
    herd = {
      server_type = "cx22"
      datacenter  = "nbg1-dc3"
    }
  }
}

module "hcloud" {
  source      = "./modules/hcloud"
  for_each    = local.nodes
  hostname    = each.key
  fqdn        = "${each.key}.heyi7086.com"
  datacenter  = each.value.datacenter
  server_type = each.value.server_type
}

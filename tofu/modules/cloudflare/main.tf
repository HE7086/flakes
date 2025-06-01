variable "account_id" {
  type = string
}

variable "zone" {
  type = string
}

variable "records" {
  type = map(map(string))
}

terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

locals {
  zones_flattened = tomap({
    for record in flatten([
      for type, type_data in var.records : [
        for name, content in type_data : {
          type    = type
          name    = name
          content = content
        }
      ]
    ]) : "${record.name}.${var.zone}_${record.type}" => record
  })
}

# TODO: use resource when server issue fixed
# resource "cloudflare_account" "main" {
#   name = "he7086"
#   type = "standard"
# }

resource "cloudflare_zone" "zone" {
  account = {
    id = var.account_id
  }
  name = var.zone
}

resource "cloudflare_dns_record" "dns_records" {
  for_each = local.zones_flattened

  zone_id = cloudflare_zone.zone.id
  # HACK: https://github.com/cloudflare/terraform-provider-cloudflare/issues/5517#issuecomment-2917715192
  # name    = each.value.name
  name    = each.value.name == "@" ? var.zone : (each.value.name == var.zone ? var.zone : "${each.value.name}.${var.zone}")
  type    = each.value.type
  content = each.value.content
  proxied = false
  ttl     = 1
}

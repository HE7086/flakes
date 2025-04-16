provider "cloudflare" {
  api_token = local.secrets.cloudflare.api_token
}

locals {
  zones = {
    "heyi7086.com" = {
      A = {
        herd = module.hcloud["herd"].ipv4
        # fridge = #ddns
        toaster = "130.61.106.117"
      }
      AAAA = {
        herd = module.hcloud["herd"].ipv6
        # fridge = #ddns
        toaster = "2603:c020:8007:f222:194:a7be:c02e:2d34"
      }
      CNAME = {
        blog        = "he7086.github.io"
        hass        = "fridge.heyi7086.com"
        vault       = "fridge.heyi7086.com"
        repo        = "herd.heyi7086.com"
        "*"         = "herd.heyi7086.com"
        "@"         = "herd.heyi7086.com"
        "*.herd"    = "herd.heyi7086.com"
        "*.fridge"  = "fridge.heyi7086.com"
        "*.toaster" = "toaster.heyi7086.com"
      }
      # MX = {}
      TXT = {
        "_dmarc"                              = "\"v=DMARC1;  p=none; rua=mailto:49bd918599184cc9822dd895640ce3d4@dmarc-reports.cloudflare.net\""
        "_github-pages-challenge-he7086.blog" = "\"b7af5788718d4e4b2357532df01fb5\""
        "heyi7086.com"                        = "\"v=spf1 include:_spf.mx.cloudflare.net include:_spf.google.com ~all\""
      }
    }
  }
  zones_flattened = tomap({
    for record in flatten([
      for zone, zone_data in local.zones : [
        for type, type_data in zone_data : [
          for name, content in type_data : {
            zone    = zone
            type    = type
            name    = name
            content = content
          }
        ]
      ]
    ]) : "${record.zone}_${record.type}_${record.name}" => record
  })

}

# TODO: use resource when server issue fixed
# resource "cloudflare_account" "main" {
#   name = "he7086"
#   type = "standard"
# }

resource "cloudflare_zone" "zones" {
  for_each = local.zones

  account = {
    id = local.secrets.cloudflare.account_id
  }
  name = each.key
}

resource "cloudflare_dns_record" "dns_records" {
  for_each = local.zones_flattened

  zone_id = cloudflare_zone.zones[each.value.zone].id
  name    = each.value.name
  type    = each.value.type
  content = each.value.content
  proxied = false
  ttl     = 1
}

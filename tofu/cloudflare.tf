provider "cloudflare" {
  api_token = local.secrets.cloudflare.api_token
}

locals {
  zones = {
    "heyi7086.com" = {
      A = {
        herd = module.hcloud["herd"].ipv4
        # fridge = #ddns
        toaster = module.oci.ipv4
      }
      AAAA = {
        herd = module.hcloud["herd"].ipv6
        # fridge = #ddns
        toaster = module.oci.ipv6
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
}

module "cloudflare" {
  source     = "./modules/cloudflare"
  for_each   = local.zones
  zone       = each.key
  records    = each.value
  account_id = local.secrets.cloudflare.account_id
}

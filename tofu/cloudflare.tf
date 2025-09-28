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

        #---- local only services -----
        "suwayomi.fridge"     = "192.168.1.2"
        "transmission.fridge" = "192.168.1.2"
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
        "_github-pages-challenge-he7086.blog" = "\"b7af5788718d4e4b2357532df01fb5\""
        "heyi7086.com"                        = "\"v=spf1 include:_spf.mx.cloudflare.net include:_spf.google.com ~all\""
        "google._domainkey"                   = "\"v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAynnk/Y4qx2xI1BR3R8f8N/XNd1Nla36PVOVnIbPViisGI6sPo5Qk1M8CpSedSCxBGfVYxt2q4u0qb8ZHTcbfeRfJcinnEQpLQm75frEe3JFSn0o8AFBRzZ5e22mzT/8P+DV9PZSeUCJ84XsGUEiCOpkFD49RsvWTbCoPuso72ImGY7X6Zo5vOV5tM2fstY3v2\" \"4caiXLj+56vhvR0MRIHHtoLPV9H6A+EyhPTb0hHLyemmmxXXipZ1fRgO/cAOM813klctQaL9NmJDkcTvVXQqcEnWcFRMg5Z7aY5rmhhTFw750WhdNs5jGIPTANTaxGW1f2j7TDPSiSmaXEd+P4ErQIDAQAB\""
        "_dmarc"                              = "\"v=DMARC1;  p=reject; rua=mailto:report@heyi7086.com; pct=100; adkim=s; aspf=s\""
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

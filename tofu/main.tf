terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
    oci = {
      source = "oracle/oci"
    }
    sops = {
      source = "carlpett/sops"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
  encryption {
    # export TF_ENCRYPTION=...
    method "aes_gcm" "default" {
      keys = key_provider.pbkdf2.default
    }
    state {
      method   = method.aes_gcm.default
      enforced = true
    }
    plan {
      method   = method.aes_gcm.default
      enforced = true
    }
  }
}

data "sops_file" "secrets" {
  source_file = "secrets.yaml"
  input_type  = "yaml"
}

locals {
  secrets = yamldecode(data.sops_file.secrets.raw)
}

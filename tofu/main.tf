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
  }
  encryption {
    # export TF_ENCRYPTION=...
    method "aes_gcm" "default" {
      keys = key_provider.pbkdf2.default
    }
    state {
      method = method.aes_gcm.default
      enforced = true
    }
    plan {
      method = method.aes_gcm.default
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

provider "hcloud" {
  token = local.secrets.hetzner.token
}

provider "oci" {
  tenancy_ocid = local.secrets.oci.tenancy
  user_ocid    = local.secrets.oci.user
  private_key  = local.secrets.oci.private_key
  fingerprint  = local.secrets.oci.fingerprint
  region       = local.secrets.oci.region
}

provider "oci" {
  tenancy_ocid = local.secrets.oci.tenancy
  user_ocid    = local.secrets.oci.user
  private_key  = local.secrets.oci.private_key
  fingerprint  = local.secrets.oci.fingerprint
  region       = local.secrets.oci.region
}

module "oci" {
  source = "./modules/oci"
  tenancy = local.secrets.oci.tenancy
  vnic = local.secrets.oci.vnic
  availability_domain = local.secrets.oci.availability_domain
}

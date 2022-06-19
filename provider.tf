# Version requirements
terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">=4.67.3"
    }
  }
  required_version = ">= 1.0.0"
}

provider "oci" {
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.current_user_ocid
}

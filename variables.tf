# provider identity parameters
variable "fingerprint" {
  description = "fingerprint of oci api private key"
  type        = string
  default     = null
}

variable "private_key_path" {
  description = "path to oci api private key used"
  type        = string
  default     = null
}

variable "region" {
  description = "the oci region where resources will be created"
  type        = string
  # List of regions: https://docs.cloud.oracle.com/iaas/Content/General/Concepts/regions.htm#ServiceAvailabilityAcrossRegions
}

variable "tenancy_ocid" {
  description = "tenancy id where to create the sources"
  type        = string
}

variable "current_user_ocid" {
  description = "id of user that terraform will use to create the resources"
  type        = string
}

# general oci parameters

variable "compartment_ocid" {
  description = "compartment id where to create all resources"
  type        = string
}

variable "label_prefix" {
  description = "a string that will be prepended to all resources"
  type        = string
  default     = "alwaysfree"
}

# vcn parameters

variable "vcn_cidrs" {
  description = "The list of IPv4 CIDR blocks the VCN will use."
  type        = list(string)
  default     = ["10.42.0.0/16"]
}

variable "vcn_dns_label" {
  description = "A DNS label for the VCN, used in conjunction with the VNIC's hostname and subnet's DNS label to form a fully qualified domain name (FQDN) for each VNIC within this subnet"
  type        = string
  default     = "vcn"
}

variable "vcn_name" {
  description = "user-friendly name of to use for the vcn to be appended to the label_prefix"
  type        = string
  default     = "vcn"
}

# compute instance parameters

variable "instance_ad_number" {
  description = "The availability domain number of the instance. If none is provided, it will start with AD-1 and continue in round-robin."
  type        = number
  default     = null
}

variable "instance_nonflex_count" {
  description = "Number of identical non-flex instances to launch from a single module."
  type        = number
  default     = 2
}

variable "instance_flex_count" {
  description = "Number of identical flex instances to launch from a single module."
  type        = number
  default     = 2
}

variable "instance_flex_memory_in_gbs" {
  type        = number
  description = "(Updatable) The total amount of memory available to the instance, in gigabytes."
  default     = 12
}

variable "instance_flex_ocpus" {
  type        = number
  description = "(Updatable) The total number of OCPUs available to the instance."
  default     = 2
}

variable "instance_state" {
  type        = string
  description = "(Updatable) The target state for the instance. Could be set to RUNNING or STOPPED."
  default     = "RUNNING"

  validation {
    condition     = contains(["RUNNING", "STOPPED"], var.instance_state)
    error_message = "Accepted values are RUNNING or STOPPED."
  }
}

variable "shape_nonflex" {
  description = "The shape of a non-flex instance."
  type        = string
  default     = "VM.Standard.E2.1.Micro"
}

variable "shape_flex" {
  description = "The shape of a flex instance."
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "source_ocid_nonflex" {
  description = "The OCID of an image or a boot volume to use for non-flex instances, depending on the value of source_type."
  type        = string
}

variable "source_ocid_flex" {
  description = "The OCID of an image or a boot volume to use for flex instances, depending on the value of source_type."
  type        = string
}

variable "source_type" {
  description = "The source type for the instance."
  type        = string
  default     = "image"
}

# operating system parameters

variable "ssh_public_keys" {
  description = "Public SSH keys to be included in the ~/.ssh/authorized_keys file for the default user on the instance. To provide multiple keys, see docs/instance_ssh_keys.adoc."
  type        = string
  default     = null
}

# container parameters

variable "nonflex_container_image" {
  description = "The full name for a container image (non-flex instances)"
  type        = string
  default     = "ghcr.io/arriven/db1000n"
}

variable "nonflex_container_image_args" {
  description = "Command and arguments for a container image (non-flex instances)"
  type        = string
  default     = ""
}

variable "flex_container_image" {
  description = "The full name for a container image (flex instances)"
  type        = string
  default     = "ghcr.io/porthole-ascend-cinnamon/mhddos_proxy"
}

variable "flex_container_image_args" {
  description = "Command and arguments for a container image (flex instances)"
  type        = string
  default     = "--itarmy --debug --vpn"
}

# vpn parameters

variable "nonflex_vpn_vendor" {
  description = "VPN vendor. Supported vendors: protonvpn. Default: none - no VPN (nonflex instances)"
  type        = string
  default     = "none"
}

variable "flex_vpn_vendor" {
  description = "VPN vendor. Supported vendors: protonvpn. Default: none - no VPN (flex instances)"
  type        = string
  default     = "none"
}

variable "vpn_username" {
  description = "VPN username"
  type        = string
  default     = ""
}

variable "vpn_password" {
  description = "VPN password"
  type        = string
  default     = ""
}

variable "protonvpn_tier" {
  description = "ProtonVPN subscription tier (plan). 0=Free, 1=Mail Plus, 2=VPN Plus, 3=Proton Unlimited"
  type        = string
  default     = "2"
}

variable "protonvpn_server" {
  description = "ProtonVPN server country. Deafult: random"
  type        = string
  default     = "RANDOM"
}

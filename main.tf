module "vcn" {
  source  = "oracle-terraform-modules/vcn/oci"
  version = "3.4.0"

  # general oci parameters
  compartment_id = var.compartment_ocid
  label_prefix   = var.label_prefix

  # vcn parameters
  create_internet_gateway = true
  vcn_cidrs               = var.vcn_cidrs # List of IPv4 CIDRs
  vcn_dns_label           = var.vcn_dns_label
  vcn_name                = var.vcn_name
}

# * This module will create a shape-based Compute Instance. OCPU and memory values are defined by the provided value for shape.
module "instance_nonflex" {
  source  = "oracle-terraform-modules/compute-instance/oci"
  version = "2.4.0"

  # general oci parameters
  compartment_ocid = var.compartment_ocid

  # compute instance parameters
  ad_number             = var.instance_ad_number
  instance_count        = var.instance_nonflex_count
  instance_display_name = "${var.label_prefix}-nonflex"
  instance_state        = var.instance_state
  shape                 = var.shape_nonflex
  source_ocid           = var.source_ocid_nonflex
  source_type           = var.source_type

  # operating system parameters
  ssh_public_keys = var.ssh_public_keys
  user_data = base64encode(
    templatefile(
      "${path.module}/cloud-init.sh.tftpl",
      {
        image            = var.nonflex_container_image,
        args             = var.nonflex_container_image_args,
        vpn_vendor       = var.nonflex_vpn_vendor,
        vpn_username     = var.vpn_username,
        vpn_password     = var.vpn_password,
        protonvpn_tier   = var.protonvpn_tier,
        protonvpn_server = var.protonvpn_server,
      }
    )
  )

  # networking parameters
  public_ip    = "EPHEMERAL"
  subnet_ocids = [oci_core_subnet.nonflex.id]
}

# * This module will create a Flex Compute Instance, using OCPU and memory values provided to the module
module "instance_flex" {
  source  = "oracle-terraform-modules/compute-instance/oci"
  version = "2.4.0"

  # general oci parameters
  compartment_ocid = var.compartment_ocid

  # compute instance parameters
  ad_number             = var.instance_ad_number
  instance_count        = var.instance_flex_count
  instance_display_name = "${var.label_prefix}-flex"
  instance_state        = var.instance_state
  shape                 = var.shape_flex
  source_ocid           = var.source_ocid_flex
  source_type           = var.source_type

  instance_flex_memory_in_gbs = var.instance_flex_memory_in_gbs # only used if shape is Flex type
  instance_flex_ocpus         = var.instance_flex_ocpus         # only used if shape is Flex type

  # operating system parameters
  ssh_public_keys = var.ssh_public_keys
  user_data = base64encode(
    templatefile(
      "${path.module}/cloud-init.sh.tftpl",
      {
        image            = var.flex_container_image,
        args             = var.flex_container_image_args,
        vpn_vendor       = var.flex_vpn_vendor,
        vpn_username     = var.vpn_username,
        vpn_password     = var.vpn_password,
        protonvpn_tier   = var.protonvpn_tier,
        protonvpn_server = var.protonvpn_server,
      }
    )
  )

  # networking parameters
  public_ip    = "EPHEMERAL"
  subnet_ocids = [oci_core_subnet.flex.id]
}

resource "oci_core_subnet" "nonflex" {
  #Required
  cidr_block     = cidrsubnet(var.vcn_cidrs[0], 8, 0)
  compartment_id = var.compartment_ocid
  vcn_id         = module.vcn.vcn_id

  security_list_ids = [oci_core_security_list.security_list.id]

  #Optional
  display_name   = "nonflex-subnet"
  dns_label      = "nonflex"
  route_table_id = module.vcn.ig_route_id
}

resource "oci_core_subnet" "flex" {
  #Required
  cidr_block     = cidrsubnet(var.vcn_cidrs[0], 8, 1)
  compartment_id = var.compartment_ocid
  vcn_id         = module.vcn.vcn_id

  security_list_ids = [oci_core_security_list.security_list.id]

  #Optional
  display_name   = "flex-subnet"
  dns_label      = "flex"
  route_table_id = module.vcn.ig_route_id
}

resource "oci_core_security_list" "security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = module.vcn.vcn_id
  display_name   = "${var.label_prefix}SecurityList"

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      max = "22"
      min = "22"
    }
  }
}

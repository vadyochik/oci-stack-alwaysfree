output "module_vcn_ids" {
  description = "vcn and gateways information"
  value = {
    drg_id                       = module.vcn.drg_id
    internet_gateway_id          = module.vcn.internet_gateway_id
    internet_gateway_route_id    = module.vcn.ig_route_id
    nat_gateway_id               = module.vcn.nat_gateway_id
    nat_gateway_route_id         = module.vcn.nat_route_id
    service_gateway_id           = module.vcn.service_gateway_id
    vcn_dns_label                = module.vcn.vcn_all_attributes.dns_label
    vcn_default_security_list_id = module.vcn.vcn_all_attributes.default_security_list_id
    vcn_default_route_table_id   = module.vcn.vcn_all_attributes.default_route_table_id
    vcn_default_dhcp_options_id  = module.vcn.vcn_all_attributes.default_dhcp_options_id
    vcn_id                       = module.vcn.vcn_id
  }
}

output "instance_nonflex" {
  description = "ocid of created non-flex instances."
  value       = module.instance_nonflex.instances_summary
}

output "instance_flex" {
  description = "ocid of created flex instances."
  value       = module.instance_flex.instances_summary
}

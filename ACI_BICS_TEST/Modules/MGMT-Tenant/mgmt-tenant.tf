# Read vars
variable "env" {
  type    = string
  default = "ant"
}


locals {
  from_file = yamldecode(file("variables/${var.env}/vars-lab-mgmt-tenant_${var.env}.yaml"))
}

# create tenant & phy domain for testing --> this is normally imported as data
resource "aci_tenant" "tenant" {
  for_each = { for x in local.from_file.tenants : x.name => x }
  name        = each.key
}

# VRFs
resource "aci_vrf" "vrf" {
  for_each = { for x in local.from_file.VRFs : x.name => x }
  tenant_dn              = aci_tenant.tenant[each.value.tenant].id
  name                   = each.key
}

# ANP
resource "aci_application_profile" "anp" {
  for_each = { for x in local.from_file.ANPs : x.name => x }
  tenant_dn  = aci_tenant.tenant[each.value.tenant].id
  name       = each.key
}

# BD
resource "aci_bridge_domain" "bridge_domain" {
  for_each = { for x in local.from_file.BDs : x.name => x }
    tenant_dn                   = aci_tenant.tenant[each.value.tenant].id
    name                        = each.key
    relation_fv_rs_ctx          = aci_vrf.vrf[each.value.vrf].id
    multi_dst_pkt_act           = each.value.multi_dest_flood
    arp_flood                   = each.value.arp_flood
    ip_learning                 = each.value.ip_learning
    unicast_route               = each.value.unicast_route
}

# EPG
resource "aci_application_epg" "application_epg" {
    for_each = { for x in local.from_file.EPGs : x.name => x }
    application_profile_dn  = aci_application_profile.anp[each.value.anp].id
    name                    = each.key
    relation_fv_rs_bd       = aci_bridge_domain.bridge_domain[each.value.bd].id
}

# Static binding
resource "aci_epg_to_static_path" "static" {
  for_each = { for x in local.from_file.static_bindings : x.identifyer => x }
  application_epg_dn  = aci_application_epg.application_epg[each.value.epg].id
  tdn  = "topology/pod-${each.value.pod}/paths-${each.value.node}/pathep-[eth1/${each.value.port}]"
  encap  = "vlan-${each.value.vlan}"
  mode = each.value.mode
}
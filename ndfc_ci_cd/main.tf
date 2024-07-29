
resource "dcnm_vrf" "VRF-1" {
  fabric_name             = "S1-VXLAN-EVPN"
  name                    = "VRF-1"
  segment_id              = "50001"
  vlan_id                 = 2001
  vlan_name               = "VRF-1"
  description             = "VRF-1"
  intf_description        = "VRF-1"
  deploy                  = "true"
  
  attachments {
    serial_number = "99RHB5FSQSS"
    attach        = true
  }
  attachments {
    serial_number = "9Q6LEFTSEDU"
    attach        = true
  }
}


resource "dcnm_network" "NET1-VRF1" {
  fabric_name     = "S1-VXLAN-EVPN"
  name            = "NET1-VRF1"
  network_id      = "30001"
  vrf_name        = dcnm_vrf.VRF-1.name
  vlan_id         = 2301
  vlan_name       = "NET1-VRF1"
  ipv4_gateway    = "192.168.1.1/24"
  mtu             = 9216
  deploy = true
  attachments {
    serial_number = "99RHB5FSQSS"
    attach        = true
    switch_ports = ["Port-channel1000"]
  }
  attachments {
    serial_number = "9Q6LEFTSEDU"
    attach        = true
    switch_ports = ["Port-channel1000"]
  }
}

/*
// NETWORKS



resource "dcnm_network" "NET2-VRF1" {
  fabric_name     = "S1-VXLAN-EVPN"
  name            = "NET2-VRF1"
  network_id      = "30002"
  vrf_name        = dcnm_vrf.VRF-1.name
  vlan_id         = 2302
  vlan_name       = "NET2-VRF1"
  ipv4_gateway    = "192.168.2.1/24"
  mtu             = 9216
  deploy = true
  attachments {
    serial_number = "99RHB5FSQSS"
    attach        = true
    switch_ports = ["Port-channel1000"]
  }
  attachments {
    serial_number = "9Q6LEFTSEDU"
    attach        = true
    switch_ports = ["Port-channel1000"]
  }
}

resource "dcnm_network" "NET3-VRF1" {
  fabric_name     = "S1-VXLAN-EVPN"
  name            = "NET3-VRF1"
  network_id      = "30003"
  vrf_name        = dcnm_vrf.VRF-1.name
  vlan_id         = 2303
  vlan_name       = "NET3-VRF1"
  ipv4_gateway    = "192.168.3.1/24"
  mtu             = 9216
  deploy = true
  attachments {
    serial_number = "99RHB5FSQSS"
    attach        = true
    switch_ports = ["Port-channel1000"]
  }
  attachments {
    serial_number = "9Q6LEFTSEDU"
    attach        = true
    switch_ports = ["Port-channel1000"]
  }
}


*/
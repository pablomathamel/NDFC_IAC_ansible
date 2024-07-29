terraform {
  required_providers {
    aci = {
      source = "CiscoDevNet/aci"
      version = "2.7.0"
    }
  }
}


provider "aci" {
  username = "admin"
  # cisco-aci password
  password = "C1sc0123p"
  # cisco-aci url
  url      = "https://10.50.16.250:8082"
  insecure = true
  
}
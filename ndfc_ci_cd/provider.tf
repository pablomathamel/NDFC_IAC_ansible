terraform {
  required_providers {
    dcnm = {
      # The CiscoDevNet/dcnm provider supports both NDFC and DCNM
      source = "CiscoDevNet/dcnm"
      version = "1.2.7"
    }
  }
}

# Configure the provider with your Cisco dcnm/ndfc credentials.
provider "dcnm" {
  # cisco-dcnm/ndfc user name
  username = "admin"
  # cisco-dcnm/ndfc password
  password = "C1sc0123p"
  # cisco-dcnm/ndfc url
  url      = "https://dcnm.bcn:8080/"
  insecure = true
  platform = "nd"
}
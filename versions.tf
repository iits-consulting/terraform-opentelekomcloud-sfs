terraform {

  required_version = ">= 1.5.7"

  required_providers {
    opentelekomcloud = {
      source  = "opentelekomcloud/opentelekomcloud"
      version = "~> 1.35"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

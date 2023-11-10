terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "istio_traffic_routing_misconfiguration_incident" {
  source    = "./modules/istio_traffic_routing_misconfiguration_incident"

  providers = {
    shoreline = shoreline
  }
}
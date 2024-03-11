terraform {
  required_providers {
    harvester = {
      source = "harvester/harvester"
#      version = "0.4.0"
    }
  }
}

provider "harvester" {
  # Configuration options
  kubeconfig = "../harvester-kubeconfig"
}

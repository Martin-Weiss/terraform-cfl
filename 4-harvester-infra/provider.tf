terraform {
  required_providers {
    harvester = {
      source = "harvester/harvester"
    }
  }
}

provider "harvester" {
  # Configuration options
  kubeconfig = "../harvester-kubeconfig"
}

provider "kubernetes" {
  config_path    = "${path.module}/../harvester-rke2.yaml"
}

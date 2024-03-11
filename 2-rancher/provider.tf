terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "4.0.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "${path.module}/../harvester-rke2.yaml"
}

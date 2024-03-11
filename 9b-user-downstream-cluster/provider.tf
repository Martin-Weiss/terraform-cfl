terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "4.0.0"
    }
    harvester = {
      source  = "harvester/harvester"
      version = "0.6.4"
    }
  }
}

provider "rancher2" {
  api_url    = var.rancher_api_url
  token_key  = var.rancher_baerer_token
  #api_url    = file("${path.cwd}/../.rancher_api_url")
  #token_key  = file("${path.cwd}/../.rancher_baerer_token")
  insecure   = var.rancher_insecure
}

provider "harvester" {
  kubeconfig = "${path.module}/../harvester-kubeconfig"
}

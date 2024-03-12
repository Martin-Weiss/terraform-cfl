terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "4.0.0"
    }
  }
}

provider "rancher2" {
  api_url    = file("${path.cwd}/../.rancher_api_url")
  token_key  = file("${path.cwd}/../.rancher_bearer_token")
  insecure   = var.rancher_insecure
}


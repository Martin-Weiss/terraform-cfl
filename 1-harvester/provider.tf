terraform {
  required_providers {
    equinix = {
      source  = "equinix/equinix"
      version = "1.31.0"
    }
  }
}

provider "equinix" {
  auth_token = file("${path.cwd}/../.metal_auth_token")
}

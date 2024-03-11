variable "rancher_api_url" {
  default     = ""
  description = "Rancher API endpoint to manager your Harvester cluster"
}

variable "rancher_baerer_token" {
  default     = ""
  description = "Rancher Bearer Token"
}

variable "rancher_insecure" {
  default     = false
  description = "Allow insecure connections to the Rancher API"
}

variable "image" {
}

variable "image_url" {
}

variable "namespace" {
}

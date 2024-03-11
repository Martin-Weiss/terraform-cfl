variable "harvester_version" {
  default = "v1.2.1"
}

variable "node_count" {
  default = "1"
}

variable "project_name" {
  default = ""
}

variable "plan" {
  default = "m3.small.x86"
}

variable "billing_cylce" {
  default = "hourly"
}

variable "metro" {
  default = "FR"
}

variable "ipxe_script" {
  default = ""
}

variable "hostname_prefix" {
  default = ""
}

variable "spot_instance" {
  default     = true
  description = "Set to true to use spot instance instead of on demand. Also set you max bid price if true."
}

variable "max_bid_price" {
  default     = "0.11"
  description = "Maximum bid price for spot request."
}

variable "ssh_key" {
  default     = ""
  description = "Your ssh key, examples: 'github: myghid' or 'ssh-rsa AAAAblahblah== keyname'"
}

variable "num_of_vlans" {
  default     = 0
  description = "Number of VLANs to be created"
}

variable "rancher_api_url" {
  default     = ""
  description = "Rancher API endpoint to manager your Harvester cluster"
}

variable "rancher_access_key" {
  default     = ""
  description = "Rancher access key"
}

variable "rancher_secret_key" {
  default     = ""
  description = "Rancher secret key"
}

variable "rancher_insecure" {
  default     = false
  description = "Allow insecure connections to the Rancher API"
}

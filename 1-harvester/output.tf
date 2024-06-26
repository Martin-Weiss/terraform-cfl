output "harvester_vip" {
  value = "${equinix_metal_reserved_ip_block.harvester_vip.network}"
}

resource "local_file" "harvester_vip" {
    content  = equinix_metal_reserved_ip_block.harvester_vip.network
    filename = "../.harvester_vip"
}

output "harvester_url" {
  value = "https://${equinix_metal_reserved_ip_block.harvester_vip.network}/"
}

output "seed_ip" {
  value = data.equinix_metal_device.seed_device.access_public_ipv4
}

output "join_ips" {
  value = length(data.equinix_metal_device.join_devices) == 0 ? ["none"] : data.equinix_metal_device.join_devices.*.access_public_ipv4
}

output "rancher_url" {
  value = "https://${format("rancher.%s.nip.io", equinix_metal_reserved_ip_block.harvester_vip.network)}"
}

resource "local_file" "rancher_url" {
    content  = "https://${format("rancher.%s.nip.io", equinix_metal_reserved_ip_block.harvester_vip.network)}"
    filename = "../.rancher_api_url"
}

output "password" {
  value     = random_password.password.result
  sensitive = true
}

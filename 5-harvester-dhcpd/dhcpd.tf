data "harvester_image" "image" {
  name = "sles15sp5-default"
}

resource "harvester_virtualmachine" "dhcpd" {
  name      = "dhcpd"
  namespace = "default"

  description = "dhcpd"
  tags = {
    ssh-user = "sles"
  }

  cpu    = 2
  memory = "2Gi"

  hostname     = "dhcpd"

  network_interface {
    name         = "nic-mgmt"
    model        = "virtio"
  }

  network_interface {
    name         = "nic-vlan-1000"
    model        = "virtio"
    network_name = "harvester-public/vlan-1000"
  } 
  network_interface {
    name         = "nic-vlan-1001"
    model        = "virtio"
    network_name = "harvester-public/vlan-1001"
  } 
  network_interface {
    name         = "nic-vlan-1002"
    model        = "virtio"
    network_name = "harvester-public/vlan-1002"
  } 
  network_interface {
    name         = "nic-vlan-1003"
    model        = "virtio"
    network_name = "harvester-public/vlan-1003"
  } 

  disk {
    name       = "disk-0"
    type       = "disk"
    size       = "50Gi"
    bus        = "virtio"
    boot_order = 1

    image       = data.harvester_image.image.id
    auto_delete = true
  }

  cloudinit {
    user_data_secret_name    = harvester_cloudinit_secret.cloud-config-dhcpd.name
    network_data_secret_name = harvester_cloudinit_secret.cloud-config-dhcpd.name
  }

}

resource "harvester_cloudinit_secret" "cloud-config-dhcpd" {
  name      = "cloud-config-dhcpd"
  namespace = "default"

  user_data    = file("${path.module}/files/user_data.tpl") 
  network_data = file("${path.module}/files/network_data.tpl")
}

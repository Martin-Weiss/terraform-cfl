data "harvester_clusternetwork" "mgmt" {
  name = "mgmt"
}

resource "harvester_network" "vlans" {
  count=var.num_of_vlans
  name      =  "vlan-${count.index +1000 }"
  namespace =  "harvester-public"
  vlan_id = "${count.index +1000 }"
  route_mode           = "auto"
  route_dhcp_server_ip = "10.${count.index +100 }.1.1"
  cluster_network_name = data.harvester_clusternetwork.mgmt.name
}

resource "kubernetes_manifest" "ip-pools" {
  depends_on= [harvester_network.vlans]
  count=var.num_of_vlans
  manifest = yamldecode(templatefile("${path.module}/manifests/ip-pool.yaml.tpl", {
    gateway = "10.${count.index +100 }.1.1"
    name = "${count.index +1000 }"
    range-start = "10.${count.index +100 }.1.221"
    range-end = "10.${count.index +100 }.1.249"
    subnet = "10.${count.index +100 }.1.0/24"
    vlan = "vlan-${count.index +1000 }"
    vlan-namespace = "harvester-public"
  }))
}

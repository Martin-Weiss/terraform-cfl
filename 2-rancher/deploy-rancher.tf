# here we need to wait until rke2.yaml is available

resource "kubernetes_manifest" "rancher-vcluster-namespace" {
#  depends_on= [null_resource.kubeconfig]
  manifest = yamldecode(file("${path.module}/manifests/rancher-vcluster-namespace.yaml"))
}

# here we need to wait until rke2.yaml is available

resource "kubernetes_manifest" "rancher-vcluster" {
  depends_on= [kubernetes_manifest.rancher-vcluster-namespace]
#  manifest = yamldecode(templatefile("${path.module}/manifests/rancher-vcluster.yaml.tpl", { rancher-hostname = format("rancher.%s.nip.io",equinix_metal_reserved_ip_block.harvester_vip.network), rancher-password = random_password.password.result }))
#  manifest = yamldecode(templatefile("${path.module}/manifests/rancher-vcluster.yaml.tpl", { rancher-hostname = format("rancher.%s.nip.io",var.harvester_vip), rancher-password = var.rancher_password }))
  manifest = yamldecode(templatefile("${path.module}/manifests/rancher-vcluster.yaml.tpl", { rancher-hostname = format("rancher.%s.nip.io",file("${path.cwd}/../.harvester_vip")), rancher-password = var.rancher_password }))
}

# here we need to wait until the cluster is provisioned - maybe 20 minutes
# curl -Sks https://145.40.93.107/ping ? or curl -Sks https://145.40.93.107/healthz
#while true; do if curl -k --max-time 5 https://145.40.93.107/version|grep gitVerson; then echo "completed"; exit; fi; sleep 5; done

# need to add "accecpt any ssh key to rsync"
resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    command = "while true; do if curl -k --max-time 5 https://${data.equinix_metal_device.seed_device.access_public_ipv4}/version|grep gitVersion; then echo completed; rsync -e 'ssh -o StrictHostKeyChecking=no' --rsync-path=\"sudo rsync\" rancher@${data.equinix_metal_device.seed_device.access_public_ipv4}:/etc/rancher/rke2/rke2.yaml ../harvester-rke2.yaml && if [ -f /opt/homebrew/bin/gsed ]; then gsed -i \"s#127.0.0.1#${data.equinix_metal_device.seed_device.access_public_ipv4}#g\" ../harvester-rke2.yaml; exit 0; else sed -i \"s#127.0.0.1#${data.equinix_metal_device.seed_device.access_public_ipv4}#g\" ../harvester-rke2.yaml; exit 0; fi; fi; sleep 5; done"
  }
}

# need to add on destroy
#ssh-keygen -R 136.144.49.65 -f /root/.ssh/known_hosts


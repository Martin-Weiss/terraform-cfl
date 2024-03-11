resource "rancher2_cloud_credential" "harvester" {
  name = "${var.clustername}-harvester"
  harvester_credential_config {
    cluster_id = data.rancher2_cluster_v2.harvester.cluster_v1_id
    cluster_type = "imported"
    kubeconfig_content = data.rancher2_cluster_v2.harvester.kube_config
  }
}

resource "rancher2_machine_config_v2" "master" {

  generate_name = "master-"
  harvester_config {
    vm_namespace = "default"
    cpu_count = "4"
    memory_size = "8"
    disk_info = <<EOF
    {
        "disks": [{
            "imageName": "default/sles15sp5-minimal-cloud",
            "size": 40,
            "bootOrder": 1
        }]
    }
    EOF
    network_info = <<EOF
    {
        "interfaces": [{
            "networkName": "${var.vlan}"
        }]
    }
    EOF
    ssh_user = "${var.ssh_user}"
    user_data = <<EOF
    user: sles
    password: suse1234
    chpasswd:
      expire: false
    ssh_pwauth: true
    package_update: false
    write_files:
    - content: |
        PROXY_ENABLED="yes"
        HTTP_PROXY="http://10.0.2.2:3128"
        HTTPS_PROXY="http://10.0.2.2:3128"
        FTP_PROXY="http://10.0.2.2:3128"
        NO_PROXY="localhost, 127.0.0.1, 10.0.0.0/8"
      path: /etc/sysconfig/proxy
    packages:
      - qemu-guest-agent
      - iptables
    runcmd:
      - export http_proxy="http://10.0.2.2:3128"
      - export ftp_proxy="http://10.0.2.2:3128"
      - export https_proxy="http://10.0.2.2:3128"
      - export no_proxy="localhost, 127.0.0.1, 10.0.0.0/8"
      - - systemctl
        - enable
        - '--now'
        - qemu-guest-agent.service
    EOF
    network_data = <<-EOF
      version: 2
      ethernets:
        eth0:
          dhcp4: true
    EOF
  }

}

resource "rancher2_machine_config_v2" "worker" {

  generate_name = "worker-"
  harvester_config {
    vm_namespace = "default"
    cpu_count = "4"
    memory_size = "8"
    disk_info = <<EOF
    {
        "disks": [{
            "imageName": "default/sles15sp5-minimal-cloud",
            "size": 40,
            "bootOrder": 1
        }]
    }
    EOF
    network_info = <<EOF
    {
        "interfaces": [{
            "networkName": "${var.vlan}"
        }]
    }
    EOF
    ssh_user = "${var.ssh_user}"
    user_data = <<EOF
    user: sles
    password: suse1234
    chpasswd:
      expire: false
    ssh_pwauth: true
    package_update: false
    write_files:
    - content: |
        PROXY_ENABLED="yes"
        HTTP_PROXY="http://10.0.2.2:3128"
        HTTPS_PROXY="http://10.0.2.2:3128"
        FTP_PROXY="http://10.0.2.2:3128"
        NO_PROXY="localhost, 127.0.0.1, 10.0.0.0/8"
      path: /etc/sysconfig/proxy
    packages:
      - qemu-guest-agent
      - iptables
    runcmd:
      - export http_proxy="http://10.0.2.2:3128"
      - export ftp_proxy="http://10.0.2.2:3128"
      - export https_proxy="http://10.0.2.2:3128"
      - export no_proxy="localhost, 127.0.0.1, 10.0.0.0/8"
      - - systemctl
        - enable
        - '--now'
        - qemu-guest-agent.service
    EOF
    network_data = <<-EOF
      version: 2
      ethernets:
        eth0:
          dhcp4: true
    EOF
  }

}


resource "rancher2_cluster_v2" "cluster" {

  name = var.clustername
  kubernetes_version = "v1.27.10+rke2r1"
  agent_env_vars {
    name = "https_proxy"
    value = "http://10.0.2.2:3128"
  }
  agent_env_vars {
    name = "no_proxy"
    value = "localhost, 127.0.0.1, 10.0.0.0/8"
  }

  rke_config {

    machine_pools {

        name = "master"
        cloud_credential_secret_name = rancher2_cloud_credential.harvester.id

        control_plane_role = true
        etcd_role = true
        worker_role = false

        quantity = 1

        machine_config {
          kind = rancher2_machine_config_v2.master.kind
          name = rancher2_machine_config_v2.master.name
        }
    }

    machine_pools {

        name = "worker"
        cloud_credential_secret_name = rancher2_cloud_credential.harvester.id

        control_plane_role = false
        etcd_role = false
        worker_role = true

        quantity = 1

        machine_config {
          kind = rancher2_machine_config_v2.worker.kind
          name = rancher2_machine_config_v2.worker.name
        }
    }


    machine_selector_config {
      config = <<EOF
        #cloud-provider-config: file("${path.module}/csi-kubeconfig")
        cloud-provider-config: ${jsonencode(file("${path.module}/csi-kubeconfig"))}
        cloud-provider-name: "harvester"
    EOF
    }
    machine_global_config = <<EOF
cni: "calico"
EOF
    chart_values = <<EOF
harvester-cloud-provider:
  global:
    cattle:
      clusterName: "${var.clustername}"
  cloudConfigPath: /var/lib/rancher/rke2/etc/config-files/cloud-provider-config
  kube-vip:
    tolerations:
    - effect: NoSchedule
      key: node-role.kubernetes.io/control-plane
      operator: Exists
    - effect: NoExecute
      key: node-role.kubernetes.io/etcd
      operator: Exists
    - effect: NoExecute
      key: CriticalAddonsOnly
      operator: Exists
EOF
  }
}

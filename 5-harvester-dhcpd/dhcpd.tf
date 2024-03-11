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

  user_data    = <<-EOF
      #cloud-config
      user: sles
      password: suse1234
      chpasswd:
        expire: false
      ssh_pwauth: true
      package_update: false
      write_files:
      - content: |
          [Unit]
          Description=Enable NAT
          [Service]
          Type=oneshot
          ExecStart=/bin/bash -c "iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE"
          [Install]
          WantedBy=multi-user.target
        path: /etc/systemd/system/iptables.service
      - content: |
          net.ipv4.ip_forward = 1
          net.ipv6.conf.all.disable_ipv6 = 1
        path: /etc/sysctl.d/99-sysctl.conf
        owner: root:root
        permissions: '0644'
      - encoding: b64
        content: cGluZy1jaGVjayBvbjsKZGRucy11cGRhdGUtc3R5bGUgbm9uZTsKYXV0aG9yaXRhdGl2ZTsKCm9wdGlvbiBkb21haW4tbmFtZSAic3VzZSI7Cm9wdGlvbiBkb21haW4tbmFtZS1zZXJ2ZXJzIDguOC44Ljg7CmRlZmF1bHQtbGVhc2UtdGltZSA4NjQwMDsKbWF4LWxlYXNlLXRpbWUgODY0MDA7Cm9wdGlvbiBzdWJuZXQtbWFzayAyNTUuMjU1LjI1NS4wOwoKc3VibmV0IDEwLjAuMi4wIG5ldG1hc2sgMjU1LjI1NS4yNTUuMCB7fQoKc3VibmV0IDEwLjEwMC4xLjAgbmV0bWFzayAyNTUuMjU1LjI1NS4wIHsKICByYW5nZSAxMC4xMDAuMS4xMSAxMC4xMDAuMS4xOTk7CiAgb3B0aW9uIHJvdXRlcnMgMTAuMTAwLjEuMTsKfQpzdWJuZXQgMTAuMTAxLjEuMCBuZXRtYXNrIDI1NS4yNTUuMjU1LjAgewogIHJhbmdlIDEwLjEwMS4xLjExIDEwLjEwMS4xLjE5OTsKICBvcHRpb24gcm91dGVycyAxMC4xMDEuMS4xOwp9CnN1Ym5ldCAxMC4xMDIuMS4wIG5ldG1hc2sgMjU1LjI1NS4yNTUuMCB7CiAgcmFuZ2UgMTAuMTAyLjEuMTEgMTAuMTAyLjEuMTk5OwogIG9wdGlvbiByb3V0ZXJzIDEwLjEwMi4xLjE7Cn0Kc3VibmV0IDEwLjEwMy4xLjAgbmV0bWFzayAyNTUuMjU1LjI1NS4wIHsKICByYW5nZSAxMC4xMDMuMS4xMSAxMC4xMDMuMS4xOTk7CiAgb3B0aW9uIHJvdXRlcnMgMTAuMTAzLjEuMTsKfQo=
        owner: root:root
        path: /etc/dhcpd.conf
        permissions: '0644'
      zypper:
        repos:
        - id: SLE-BCI
          name: SLE-BCI
          baseurl: https://updates.suse.com/SUSE/Products/SLE-BCI/15-SP5/x86_64/product/
          enabled: 1
          autorefresh: 1
          gpgcheck: 0
        config:
          gpgcheck: "off"
          solver.onlyRequires: "true"
          download.use_deltarpm: "true"
      packages: 
      - dhcp-server
      - squid
      runcmd:
        - - systemctl
          - enable
          - '--now'
          - qemu-guest-agent
        - sed -i 's/^DHCPD_INTERFACE=.*/DHCPD_INTERFACE="ANY"/g' /etc/sysconfig/dhcpd
        - - systemctl
          - enable
          - '--now'
          - dhcpd
        - systemctl daemon-reload
        - systemctl enable --now iptables.service
        - systemctl enable --now squid.service
        - sysctl -p /etc/sysctl.d/99-sysctl.conf
      ssh_authorized_keys:
        - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD1RPbAISjVatORw9QZjLPS4h++Noq/6haXnaZjtsmQNiqVaq3v4zUTaEolrow8/fTKIwIDxLbtUyy8Y/AbDoCp3dT2fx1YCw2BCpg1fn4QxBzc7NAxA+XrUty53PZ3V2AhpJgoN5Iybjkvo0xguiPjo/W62ZRTtNssodRr/nMnwos4/Xb1VvLe5sIQIkHuLQvp9TdBJtUhf3H/zw4tiwGrI6FN6B02Q1DVAntX8BMcq0pjgF2Gd6QV1L1CTz+H+IIeevALWzJG+AeQmXE7psRPpqgMYBof2bNTTYUjpau+8/plVBoHJZCxABPALUYDGwu/m6iPdjhMFH7jxXPBaseDgTDLWthAV/4j7il2o2xVjjsJ0IfShiOvx10BIBfkAR20NLQ9ptQkHki5/TdTEDO7H9R2Sd9ktWtOaylTXXoES1cqLN/cl1VJ8oXxc+ehFFyFdCumTQKRNEPoTdXYsfMVCPkX/aklttvzv2J+/GGrruN2x1cBsR01KPVafVGuH10= root@susemanager
      EOF
  network_data = <<-EOF
      version: 2
      ethernets:
        eth0:
          dhcp4: true
        eth1:
          dhcp4: false
          addresses:
            - 10.100.1.1/24
        eth2:
          dhcp4: false
          addresses:
            - 10.101.1.1/24
        eth3:
          dhcp4: false
          addresses:
            - 10.102.1.1/24
        eth4:
          dhcp4: false
          addresses:
            - 10.103.1.1/24
      EOF

}

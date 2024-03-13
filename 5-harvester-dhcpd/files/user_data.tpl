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
- content: |
    version: 0.1
    storage:
      filesystem:
        rootdirectory: /var/lib/registry
    proxy:
      #remoteurl: https://index.docker.io/v1
      remoteurl: https://registry-1.docker.io
    http:
      addr: :5000
  path: /data/registry/config.yml 
  owner: root:root
  permissions: '0644'
- content: |
    [req]
    distinguished_name = req_distinguished_name
    req_extensions = v3_req
    prompt = no
    [req_distinguished_name]
    C = DE
    ST = BW
    O = SUSE
    CN = 10.0.2.2
    [v3_req]
    extendedKeyUsage = serverAuth
    subjectAltName = @alt_names
    [alt_names]
    IP.1 = "10.0.2.2"
    DNS.1 = *
    DNS.2 = *.*
  path: /data/certificates/req.conf 
  owner: root:root
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
- podman
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
  - openssl genrsa -out /data/certificates/rootca.key 2048
  - openssl req -x509 -new -nodes -key /data/certificates/rootca.key -sha256 -days 3600 -out /data/certificates/rootca.crt  -subj "/C=DE/ST=BW/O=SUSE/CN=10.0.2.2"
  - openssl genrsa -out /data/certificates/10.0.2.2.key 2048
  - chmod 644 /data/certificates/10.0.2.2.key
  - openssl req -new -nodes -subj "/C=DE/ST=BW/O=SUSE/CN=10.0.2.2" -sha256 -key /data/certificates/10.0.2.2.key -out /data/certificates/10.0.2.2.csr -config /data/certificates/req.conf
  - openssl x509 -req -in /data/certificates/10.0.2.2.csr -CA /data/certificates/rootca.crt -CAkey /data/certificates/rootca.key -CAcreateserial -out /data/certificates/10.0.2.2.crt -days 3650 -sha256 -extfile /data/certificates/req.conf -extensions v3_req
  - mkdir -p /data/registry/data
  - chmod 777 /data/registry/data
  - podman run -d --restart=always --name registry -v /data/registry/config.yml:/etc/docker/registry/config.yml -v /data/registry/data:/var/lib/registry -v /data/certificates:/certificates:ro -v /data/certificates/rootca.crt:/etc/ssl/certs/ca-certificates.crt:ro -e REGISTRY_HTTP_TLS_CERTIFICATE=/certificates/10.0.2.2.crt -e REGISTRY_HTTP_TLS_KEY=/certificates/10.0.2.2.key -e REGISTRY_HTTP_SECRET="registry1234!" -p 5000:5000 registry.suse.com/suse/registry:2.8-19.2
  - podman generate systemd --restart-policy=always registry -n > /etc/systemd/system/container-registry.service
  - systemctl daemon-reload
  - systemctl enable --now container-registry.service
ssh_authorized_keys:
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD1RPbAISjVatORw9QZjLPS4h++Noq/6haXnaZjtsmQNiqVaq3v4zUTaEolrow8/fTKIwIDxLbtUyy8Y/AbDoCp3dT2fx1YCw2BCpg1fn4QxBzc7NAxA+XrUty53PZ3V2AhpJgoN5Iybjkvo0xguiPjo/W62ZRTtNssodRr/nMnwos4/Xb1VvLe5sIQIkHuLQvp9TdBJtUhf3H/zw4tiwGrI6FN6B02Q1DVAntX8BMcq0pjgF2Gd6QV1L1CTz+H+IIeevALWzJG+AeQmXE7psRPpqgMYBof2bNTTYUjpau+8/plVBoHJZCxABPALUYDGwu/m6iPdjhMFH7jxXPBaseDgTDLWthAV/4j7il2o2xVjjsJ0IfShiOvx10BIBfkAR20NLQ9ptQkHki5/TdTEDO7H9R2Sd9ktWtOaylTXXoES1cqLN/cl1VJ8oXxc+ehFFyFdCumTQKRNEPoTdXYsfMVCPkX/aklttvzv2J+/GGrruN2x1cBsR01KPVafVGuH10= root@susemanager


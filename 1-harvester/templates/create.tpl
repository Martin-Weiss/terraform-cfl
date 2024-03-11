#cloud-config
scheme_version: 1
token: "${token}"
os:
  ssh_authorized_keys:
  - "${ssh_key}"
  password: "${password}"
  hostname: "${hostname_prefix}-${count}"
install:
  mode: create
  device: /dev/sda
  iso_url: https://releases.rancher.com/harvester/${version}/harvester-${version}-amd64.iso
  tty: ttyS1,115200n8
  vip: ${vip}
  vip_mode: static
  device: /dev/sda
  data_disk: /dev/sdb
  addons:
    rancher_monitoring:
      enabled: true
      values_content: ""
    rancher_logging:
      enabled: true
      values_content: ""

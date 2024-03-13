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


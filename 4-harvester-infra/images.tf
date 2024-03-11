resource "harvester_image" "sles15sp5-default" {
  name      = "sles15sp5-default"
  namespace = "default"

  display_name = "sles15sp5-default"
  source_type  = "download"
  url          = "https://download.opensuse.org/repositories/home:/mweiss2:/branches:/SUSE:/Templates:/Images:/SLE-15-SP5/images/SLES15-SP5-Minimal-VM.x86_64-Cloud-Build5.1.qcow2"
}


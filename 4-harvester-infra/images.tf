resource "harvester_image" "sles15sp5-default" {
  name      = var.image
  namespace = "default"

  display_name = var.image
  source_type  = "download"
  url          = var.image_url
}


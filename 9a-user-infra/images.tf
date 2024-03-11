resource "harvester_image" "sles" {
  name      = var.image
  namespace = var.namespace

  display_name = var.image
  source_type  = "download"
  url          = var.image_url
}


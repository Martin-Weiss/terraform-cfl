resource "harvester_ssh_key" "suse-ssh-key" {
  name      = "suse-ssh-key"
  namespace = "default"

  public_key = var.suse-ssh-key
}

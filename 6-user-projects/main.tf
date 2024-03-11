resource "random_password" "password" {
  length  = 12
  special = false
}

resource "rancher2_user" "user" {
  count            = var.number-of-users
  name = "${var.user-name-prefix}-${count.index}"
  username = "${var.user-name-prefix}-${count.index}"
  password = random_password.password.result
  enabled = true
}

# user-base is required to allow creation of API tokens
resource "rancher2_global_role_binding" "global-binding-user" {
  count            = var.number-of-users
  name = "${var.user-name-prefix}-${count.index}-global-binding-user"
  global_role_id = "user-base"
  user_id = rancher2_user.user[count.index].id
}

resource "rancher2_global_role_binding" "global-binding-clusters-create" {
  count            = var.number-of-users
  name = "${var.user-name-prefix}-${count.index}-global-binding-clusters-create"
  global_role_id = "clusters-create"
  user_id = rancher2_user.user[count.index].id
}

resource "rancher2_project" "project" {
  count            = var.number-of-users
  name = "${var.user-name-prefix}-${count.index}"
  cluster_id = data.rancher2_cluster.harvester.id
}

resource "rancher2_project_role_template_binding" "project-binding" {
  count            = var.number-of-users
  name = "${var.user-name-prefix}-${count.index}-project-binding"
  project_id = rancher2_project.project[count.index].id
  role_template_id = "project-owner"
  user_id = rancher2_user.user[count.index].id
}

resource "null_resource" "start" {
  provisioner "local-exec" {
    command = "echo depends_id=${var.depends_id}"
  }
}

locals {
  variables_or_none = "${length(keys(var.variables)) == 0 ?
    ""
    :
    "${join(" ", formatlist("-v %s=%s", keys(var.variables), values(var.variables)))}"
  }"
}

module "stack_install" {
  source  = "matti/resource/shell"
  version = "0.3.0"

  depends_id = "${null_resource.start.id}"

  command              = "kontena stack install --no-deploy ${local.variables_or_none} --name ${var.name} ${var.stack}"
  command_when_destroy = "kontena stack rm --force ${var.name}"
}

module "stack_upgrade" {
  source  = "matti/resource/shell"
  version = "0.3.0"

  depends_id = "${module.stack_install.id}"
  trigger    = "${local.variables_or_none}"
  command    = "kontena stack upgrade --no-deploy ${local.variables_or_none} ${var.name}"
}

module "stack_deploy" {
  source  = "matti/resource/shell"
  version = "0.3.0"

  depends_id = "${module.stack_upgrade.id}"
  trigger    = "${module.stack_upgrade.id}"
  command    = "kontena stack deploy ${var.name}"
}

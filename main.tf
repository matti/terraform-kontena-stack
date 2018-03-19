resource "null_resource" "start" {
  triggers {
    depends_id = "${var.depends_id}"
  }
}

locals {
  variables_or_none = "${length(keys(var.variables)) == 0 ?
    ""
    :
    "${join(" ", formatlist("-v %s=%s", keys(var.variables), values(var.variables)))}"
  }"
}

resource "null_resource" "install" {
  depends_on = ["null_resource.start"]

  provisioner "local-exec" {
    command = "kontena stack install --no-deploy ${local.variables_or_none} --name ${var.name} ${var.stack}"
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "kontena stack rm --force ${var.name}"
  }
}

resource "null_resource" "upgrade" {
  depends_on = ["null_resource.install"]

  triggers {
    variables = "${jsonencode(var.variables)}"
  }

  provisioner "local-exec" {
    command = "kontena stack upgrade --no-deploy ${local.variables_or_none} ${var.name} ${var.stack}"
  }
}

resource "null_resource" "deploy" {
  depends_on = ["null_resource.install", "null_resource.upgrade"]

  triggers {
    variables = "${jsonencode(var.variables)}"
  }

  provisioner "local-exec" {
    command = "kontena stack deploy ${var.name}"
  }
}

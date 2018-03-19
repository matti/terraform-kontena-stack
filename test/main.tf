module "ingress_lb" {
  source = ".."

  stack = "kontena/ingress-lb"
  name  = "ingressi"

  variables = {
    lb_stats_password = "myweakerpassword"
  }
}

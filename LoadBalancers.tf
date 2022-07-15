module "alb" {
  source             = "terraform-aws-modules/alb/aws"
  version            = "6.7.0"
  name               = "${var.project-name}-alb"
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets            = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]
  security_groups    = [module.vpc.default_security_group_id]
  target_groups = [
    {
      name             = "${var.project-name}-tg"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"

      stickiness = {
        enabled  = true
        duration = "300"
        type     = "lb_cookie"
      }

      health_check = {
        path                = "/license.txt"
        healthy_threshold   = 2
        unhealthy_threshold = 5
        timeout             = 10
        interval            = 30
        matcher             = "200"
      }
    }
  ]

  /*http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]*/

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.acm.acm_certificate_arn
      target_group_index = 0
    }
  ]
}

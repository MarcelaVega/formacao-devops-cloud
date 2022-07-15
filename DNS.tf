data "aws_elb_hosted_zone_id" "main" {}

resource "aws_route53_record" "www" {
  zone_id = var.dns.zone_id
  name    = "www.${var.dns.name}"
  type    = "A"

  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "main" {
  zone_id = var.dns.zone_id
  name    = var.dns.name
  type    = "A"

  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "cdn" {
  zone_id = var.dns.zone_id
  name    = "media"
  type    = "CNAME"
  ttl     = "300"

  records        = [module.cloudfront.cloudfront_distribution_domain_name]  
}
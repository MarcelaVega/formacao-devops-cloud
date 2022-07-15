module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 3.0"

  domain_name  = var.dns.name
  zone_id      = var.dns.zone_id

  subject_alternative_names = [
    "*.${var.dns.name}"
  ]

  wait_for_validation = true

  tags = {
    Name = var.dns.name
  }
}
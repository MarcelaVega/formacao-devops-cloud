module "cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "2.9.3"

  aliases = ["media.${var.dns.name}"]

  comment             = "${var.project-name} CloudFront"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false

  create_origin_access_identity = true
  origin_access_identities = {
    s3_bucket_one = "media.${var.dns.name}.s3.${var.provider-param.region}.amazonaws.com"
  }

  #logging_config = {
  #  bucket = "logs-my-cdn.s3.amazonaws.com"
  #}

  origin = {
        s3_one = {
      domain_name = "media.${var.dns.name}.s3.amazonaws.com"
      s3_origin_config = {
        origin_access_identity = "s3_bucket_one"
      }
    }
  }

  default_cache_behavior = {
    target_origin_id       = "s3_one"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD", "OPTIONS"]
      cached_methods  = ["GET", "HEAD"]
      compress        = true
      query_string    = true
    }

    viewer_certificate = {
    acm_certificate_arn = module.acm.acm_certificate_arn
    ssl_support_method  = "sni-only"
  }
}
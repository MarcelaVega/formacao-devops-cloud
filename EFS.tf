module "efs" {
  source  = "cloudposse/efs/aws"
  version = "0.32.6"

  namespace = "www"
  stage     = lookup(var.env, var.provider-param.region)
  name      = var.project-name
  region    = var.provider-param.region
  vpc_id    = module.vpc.vpc_id
  subnets   = module.vpc.private_subnets[*]

  allowed_security_group_ids = [module.vpc.default_security_group_id]
}

resource "aws_efs_access_point" "efs-ap" {
  file_system_id = module.efs.id
}
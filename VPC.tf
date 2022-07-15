module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "3.12.0"
  name                 = "${var.project-name}-vpc-${lookup(var.env, var.provider-param.region)}"
  cidr                 = var.vpc_cidr
  azs                  = lookup(var.vpc_azs, var.provider-param.region)
  private_subnets      = var.vpc_private_subnets
  public_subnets       = var.vpc_public_subnets
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project-name}-vpc-${lookup(var.env, var.provider-param.region)}"
    Terraform   = "true"
    Environment = lookup(var.env, var.provider-param.region)
  }

  default_security_group_tags = {
    Name = "${var.project-name}-sg"
  }

  dhcp_options_tags = {
    Name = "${var.project-name}-dhcp"
  }

  igw_tags = {
    Name = "${var.project-name}-igw"
  }

  private_acl_tags = {
    Name = "${var.project-name}-private-acl"
  }

  public_acl_tags = {
    Name = "${var.project-name}-public-acl"
  }

  private_route_table_tags = {
    Name = "${var.project-name}-private-rt"
  }

  public_route_table_tags = {
    Name = "${var.project-name}-public-rt"
  }
}

resource "aws_ec2_tag" "sg" {
  resource_id = module.vpc.default_security_group_id
  key         = "Name"
  value       = "${var.project-name}-sg"
}

resource "aws_ec2_tag" "internal-sg" {
  depends_on  = [module.efs]
  resource_id = module.efs.security_group_id
  key         = "Name"
  value       = "${var.project-name}-internal-sg"
}

resource "aws_security_group_rule" "HTTP" {
  description       = "Allow HTTP traffic"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpc.default_security_group_id
}

resource "aws_security_group_rule" "HTTPS" {
  description       = "Allow HTTPS traffic"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpc.default_security_group_id
}

resource "aws_security_group_rule" "RDS" {
  description              = "Allow MySQL traffic"
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = module.vpc.default_security_group_id
  security_group_id        = module.efs.security_group_id
}

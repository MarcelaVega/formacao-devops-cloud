module "db" {
  source                              = "terraform-aws-modules/rds/aws"
  version                             = "3.1.0"
  identifier                          = "mysql-${var.project-name}"
  engine                              = "mysql"
  engine_version                      = "8.0.27"
  instance_class                      = "db.t2.micro"
  allocated_storage                   = 20
  iam_database_authentication_enabled = true
  vpc_security_group_ids              = [module.efs.security_group_id]

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = module.vpc.private_subnets[*]

  # DB parameter group
  family = "mysql8.0"

  # DB option group
  major_engine_version = "8.0"

  # DB creation parameters
  name     = var.project-name
  username = var.db-param.user
  password = random_password.db_password.result
  port     = var.db-param.port

  # Free tier definitons
  skip_final_snapshot     = true
  backup_retention_period = 0

}

resource "random_password" "db_password" {
  length           = 20
  special          = true
  override_special = "_"
}

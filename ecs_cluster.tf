resource "aws_ecs_cluster" "prod-cluster" {
  name = "wordpress-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "${var.project-name}-${lookup(var.env, var.provider-param.region)}-cluster"
  }
}

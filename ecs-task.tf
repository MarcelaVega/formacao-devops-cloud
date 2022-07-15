resource "aws_ecs_task_definition" "wordpress-task" {
  family = "${var.project-name}-task-${lookup(var.env, var.provider-param.region)}"

  volume {
    name = "www"

    efs_volume_configuration {
      file_system_id     = module.efs.id
      root_directory     = "/"
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.efs-ap.id
      }
    }
  }

  container_definitions = jsonencode([
    {
      name                  = "ecs-${var.project-name}"
      image                 = var.ecs-image
      cpu                   = 0
      memory                = 256
      essential             = true
      taskRoletask_role_arn = aws_iam_role.ecs-role.arn

      portMappings = [
        {
          containerPort = 80
          hostPort      = 0
        }
      ]

      mountPoints : [
        {
          sourceVolume  = "www",
          containerPath = "/var/www/html",
          readOnly      = false
        }
      ]

      environment : [
        {
          name  = "WORDPRESS_DB_HOST"
          value = module.db.db_instance_endpoint
        },
        {
          name : "WORDPRESS_DB_NAME"
          value : var.project-name
        },
        {
          name : "WORDPRESS_DB_PASSWORD"
          value : random_password.db_password.result
        },
        {
          name : "WORDPRESS_DB_USER"
          value : var.db-param.user
        }
      ]
    }
  ])
}

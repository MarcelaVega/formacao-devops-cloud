# Delay for cluster is deployable
/*resource "null_resource" "delay" {
  depends_on = [module.db]

  provisioner "local-exec" {
    command = "sleep 60"
  }
}*/

resource "aws_ecs_service" "ecs-service" {
  #depends_on                        = [null_resource.delay]
  name                              = "${var.project-name}-service-${lookup(var.env, var.provider-param.region)}"
  cluster                           = aws_ecs_cluster.prod-cluster.id
  task_definition                   = aws_ecs_task_definition.wordpress-task.arn
  desired_count                     = var.scaling-ecs-param.desired
  health_check_grace_period_seconds = 15


  load_balancer {
    target_group_arn = module.alb.target_group_arns[0]
    container_name   = "ecs-${var.project-name}"
    container_port   = 80
  }
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = var.scaling-ecs-param.max
  min_capacity       = var.scaling-ecs-param.min
  resource_id        = "service/${aws_ecs_cluster.prod-cluster.name}/${aws_ecs_service.ecs-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy" {
  name               = "${var.project-name}-Requests"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${module.alb.lb_arn_suffix}/${module.alb.target_group_arn_suffixes[0]}"
    }
    target_value       = 30
    scale_in_cooldown  = 30
    scale_out_cooldown = 30


  }
}

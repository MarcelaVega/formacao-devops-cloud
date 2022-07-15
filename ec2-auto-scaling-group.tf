resource "aws_autoscaling_group" "group" {
  name                      = var.project-name
  max_size                  = var.scaling-group-param.max
  min_size                  = var.scaling-group-param.min
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = var.scaling-group-param.desired
  force_delete              = true
  launch_configuration      = aws_launch_configuration.instance.name
  vpc_zone_identifier       = module.vpc.public_subnets[*]

  tag {
    key                 = "Name"
    value               = "${var.project-name}-cluster-scaled"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "instance" {
  name                 = "${var.project-name}-Scaled"
  image_id             = data.aws_ami.amazon_ecs.id
  instance_type        = var.scaling-group-param.instance_type
  security_groups      = [module.vpc.default_security_group_id]
  user_data            = file("userdata-docker.sh")
  iam_instance_profile = aws_iam_role.ec2-role.name
  key_name             = var.ec2-key
}

resource "aws_autoscaling_policy" "bat" {
  name                   = "${var.project-name}-instance-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.group.name
}

resource "aws_cloudwatch_metric_alarm" "ec2-alarm" {
  alarm_name                = "${var.project-name}-EC2-HIGH"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  datapoints_to_alarm       = "1"
  threshold                 = "2"
  alarm_description         = "Tasks sum/cluster instances"
  insufficient_data_actions = []

  alarm_actions = [aws_autoscaling_policy.bat.arn]

  metric_query {
    id          = "e1"
    expression  = "m1/m2"
    label       = "TaskCount/EC2-Instance"
    return_data = "true"
  }

  metric_query {
    id = "m1"

    metric {
      metric_name = "DesiredTaskCount"
      namespace   = "ECS/ContainerInsights"
      period      = "60"
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        ClusterName = aws_ecs_cluster.prod-cluster.name
        ServiceName = aws_ecs_service.ecs-service.name
      }
    }
  }

  metric_query {
    id = "m2"

    metric {
      metric_name = "ContainerInstanceCount"
      namespace   = "ECS/ContainerInsights"
      period      = "60"
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        ClusterName = aws_ecs_cluster.prod-cluster.name
      }
    }
  }
}

resource "aws_autoscaling_policy" "LOW" {
  name                   = "${var.project-name}-instance-policy-LOW"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.group.name
}

resource "aws_cloudwatch_metric_alarm" "ec2-LOW" {
  alarm_name                = "${var.project-name}-EC2-LOW"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "1"
  datapoints_to_alarm       = "1"
  threshold                 = "2"
  alarm_description         = "Tasks sum/cluster instances"
  insufficient_data_actions = []

  alarm_actions = [aws_autoscaling_policy.LOW.arn]

  metric_query {
    id          = "e1"
    expression  = "m1/m2"
    label       = "TaskCount/EC2-Instance"
    return_data = "true"
  }

  metric_query {
    id = "m1"

    metric {
      metric_name = "DesiredTaskCount"
      namespace   = "ECS/ContainerInsights"
      period      = "60"
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        ClusterName = aws_ecs_cluster.prod-cluster.name
        ServiceName = aws_ecs_service.ecs-service.name
      }
    }
  }

  metric_query {
    id = "m2"

    metric {
      metric_name = "ContainerInstanceCount"
      namespace   = "ECS/ContainerInsights"
      period      = "60"
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        ClusterName = aws_ecs_cluster.prod-cluster.name
      }
    }
  }
}

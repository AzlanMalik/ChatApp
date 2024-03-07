/* -------------------------------------------------------------------------- */
/*                               ECS AUTOSCALING                              */
/* -------------------------------------------------------------------------- */

/* ----------------------------- APP SERVICE AUTOSCALING ---------------------------- */
resource "aws_appautoscaling_target" "app-ecs-target" {
  max_capacity       = var.app-max-capacity
  min_capacity       = var.app-min-capacity
  resource_id        = "service/${aws_ecs_cluster.my-ecs-cluster.name}/${aws_ecs_service.ecs-service-app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "app-ecs-policy-memory" {
  name               = "${var.app-name}-${var.environment}-app-memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.app-ecs-target.resource_id
  scalable_dimension = aws_appautoscaling_target.app-ecs-target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.app-ecs-target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value = 80
  }
}

resource "aws_appautoscaling_policy" "app-ecs-policy-cpu" {
  name               = "${var.app-name}-${var.environment}-app-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.app-ecs-target.resource_id
  scalable_dimension = aws_appautoscaling_target.app-ecs-target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.app-ecs-target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 80
  }
}

/* ----------------------------- DATABASE SERVICE AUTOSCALING ----------------------------- */
resource "aws_appautoscaling_target" "db-ecs-target" {
  max_capacity       = var.db-max-capacity
  min_capacity       = var.db-min-capacity
  resource_id        = "service/${aws_ecs_cluster.my-ecs-cluster.name}/${aws_ecs_service.ecs-service-db.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "db-ecs-policy-memory" {
  name               = "${var.app-name}-${var.environment}-db-memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.db-ecs-target.resource_id
  scalable_dimension = aws_appautoscaling_target.db-ecs-target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.db-ecs-target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value = 80
  }
}

resource "aws_appautoscaling_policy" "db-ecs-policy-cpu" {
  name               = "${var.app-name}-${var.environment}-db-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.db-ecs-target.resource_id
  scalable_dimension = aws_appautoscaling_target.db-ecs-target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.db-ecs-target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 80
  }
}
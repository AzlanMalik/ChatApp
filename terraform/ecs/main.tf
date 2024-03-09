# Conditional Statement for Prod and Testing/Staging environment DB and App image urls
locals {
  db-image = var.environment == "prod" ? "${aws_ecr_repository.my-ecr-repo[0].repository_url}:${var.app-name}-app-v1" : var.app-ecr-url
  app-image = var.environment == "prod" ? "${aws_ecr_repository.my-ecr-repo[0].repository_url}:${var.app-name}-db-v1" : var.app-ecr-url
}

/* -------------------------------------------------------------------------- */
/*                                 ECS CLUSTER                                */
/* -------------------------------------------------------------------------- */
resource "aws_ecs_cluster" "my-ecs-cluster" {
  name = "${var.app-name}-${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

/* ---------------------------- CLOUDWATCH GROUP ---------------------------- */
resource "aws_cloudwatch_log_group" "log-group" {
  name = "${var.app-name}-${var.environment}-logs"

  tags = {
    Application = var.app-name
    Environment = var.environment
  }
}



/* -------------------------------------------------------------------------- */
/*                  ECS TASK DEFINITION  FOR PHP APP                          */
/* -------------------------------------------------------------------------- */

resource "aws_ecs_task_definition" "my-ecs-task-app" {
  family                   = "${var.app-name}-${var.environment}-app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.app-cpu
  memory                   = var.app-memory
  execution_role_arn       = aws_iam_role.ecs-task-execution-role.arn
  task_role_arn            = aws_iam_role.ecs-task-execution-role.arn
  container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "app",
    "image": "${local.app-image}", 
    "cpu": ${var.app-cpu},
    "memory": ${var.app-memory},
    "essential": true,
     "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80,
        "protocol": "tcp",
        "name": "app-port"
      }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.log-group.id}",
          "awslogs-region": "${var.aws-region}",
          "awslogs-stream-prefix": "${var.app-name}-app-${var.environment}"
        }
      }
  }
]
TASK_DEFINITION

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}


/* -------------------------------------------------------------------------- */
/*                         ECS TASK DEFINITION FOR DB                         */
/* -------------------------------------------------------------------------- */

resource "aws_ecs_task_definition" "my-ecs-task-db" {
  family                   = "${var.app-name}-${var.environment}-db"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.db-cpu
  memory                   = var.db-memory
  execution_role_arn       = aws_iam_role.ecs-task-execution-role.arn
  task_role_arn            = aws_iam_role.ecs-task-execution-role.arn
  container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "db",
    "image": "${local.db-image}", 
    "cpu": ${var.db-cpu},
    "memory": ${var.db-memory},
    "essential": true,
    "environment": [],
     "portMappings": [
      {
        "containerPort": 3306,
        "hostPort": 3306,
        "protocol": "tcp",
        "name": "db-port"
      }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.log-group.id}",
          "awslogs-region": "${var.aws-region}",
          "awslogs-stream-prefix": "${var.app-name}-db-${var.environment}"
        }
      }
  }
]
TASK_DEFINITION

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

/* ------------------------- ECS TASK EXECUTION ROLE ------------------------ */


resource "aws_iam_role" "ecs-task-execution-role" {
  name = "${var.app-name}-${var.environment}-ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy" {
  role       = aws_iam_role.ecs-task-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


/* -------------------------------------------------------------------------- */
/*                                 ECS SERVICE                                */
/* -------------------------------------------------------------------------- */
resource "aws_ecs_service" "ecs-service-app" {
  name                 = "app"
  cluster              = aws_ecs_cluster.my-ecs-cluster.id
  task_definition      = aws_ecs_task_definition.my-ecs-task-app.id
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = var.app-min-capacity
  force_new_deployment = true

  network_configuration {
    subnets          = aws_subnet.private-subnet.*.id
    assign_public_ip = false
    security_groups = [
      aws_security_group.my-security-group.id,
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.my-alb-target-group.arn
    container_name   = "app"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.my-lb-listener]
}

/* ------------------------------- DB SERVICE ------------------------------- */
resource "aws_ecs_service" "ecs-service-db" {
  name                 = "db"
  cluster              = aws_ecs_cluster.my-ecs-cluster.id
  task_definition      = aws_ecs_task_definition.my-ecs-task-db.id
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = var.db-min-capacity
  force_new_deployment = true

  network_configuration {
    subnets          = aws_subnet.private-subnet.*.id
    assign_public_ip = false
    security_groups = [
      aws_security_group.my-security-group.id
    ]
  }
}


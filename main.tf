provider "aws" {
  region = var.aws_region
}

# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ALB for Production
resource "aws_lb" "prod_alb" {
  name               = "${var.environment}-prod-alb"
  internal           = false
  security_groups    = [var.alb_security_group_id]
  subnets            = var.alb_subnets
  load_balancer_type = "application"
}

# ALB for Testing
resource "aws_lb" "test_alb" {
  name               = "${var.environment}-test-alb"
  internal           = false
  security_groups    = [var.alb_security_group_id]
  subnets            = var.alb_subnets
  load_balancer_type = "application"
}

# ECS Cluster for Production
resource "aws_ecs_cluster" "prod_cluster" {
  name = "${var.environment}-prod-cluster"
}

# ECS Cluster for Testing
resource "aws_ecs_cluster" "test_cluster" {
  name = "${var.environment}-test-cluster"
}

# ECS Task Definition for Production
resource "aws_ecs_task_definition" "prod_task" {
  family                   = "prod-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  container_definitions    = file("${path.module}/container_definitions.json")
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
}

# ECS Task Definition for Testing
resource "aws_ecs_task_definition" "test_task" {
  family                   = "test-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  container_definitions    = file("${path.module}/container_definitions.json")
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
}

# ECS Service for Production
resource "aws_ecs_service" "prod_service" {
  name            = "${var.environment}-prod-service"
  cluster         = aws_ecs_cluster.prod_cluster.id
  task_definition = aws_ecs_task_definition.prod_task.arn
  launch_type     = "FARGATE"
  desired_count   = var.desired_count

  load_balancer {
    target_group_arn = aws_lb_target_group.prod_tg.arn
    container_name   = "app"
    container_port   = 80
  }

  network_configuration {
    subnets         = var.alb_subnets
    security_groups = [var.alb_security_group_id]
    assign_public_ip = true
  }
}

# ECS Service for Testing
resource "aws_ecs_service" "test_service" {
  name            = "${var.environment}-test-service"
  cluster         = aws_ecs_cluster.test_cluster.id
  task_definition = aws_ecs_task_definition.test_task.arn
  launch_type     = "FARGATE"
  desired_count   = var.desired_count

  load_balancer {
    target_group_arn = aws_lb_target_group.test_tg.arn
    container_name   = "app"
    container_port   = 80
  }

  network_configuration {
    subnets         = var.alb_subnets
    security_groups = [var.alb_security_group_id]
    assign_public_ip = true
  }
}

# Route 53 Record for Production
resource "aws_route53_record" "prod_weighted" {
  zone_id = var.route53_zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = 60

  weighted_routing_policy {
    weight = var.prod_weight
  }

  alias {
    name                   = aws_lb.prod_alb.dns_name
    zone_id                = aws_lb.prod_alb.zone_id
    evaluate_target_health = true
  }
}

# Route 53 Record for Testing
resource "aws_route53_record" "test_weighted" {
  zone_id = var.route53_zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = 60

  weighted_routing_policy {
    weight = var.test_weight
  }

  alias {
    name                   = aws_lb.test_alb.dns_name
    zone_id                = aws_lb.test_alb.zone_id
    evaluate_target_health = true
  }
}


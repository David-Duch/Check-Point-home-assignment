resource "aws_ecs_cluster" "this" {
  name = "${var.service_name}-cluster-${terraform.workspace}"
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.service_name}-task-role-${terraform.workspace}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })

  tags = { Project = var.project }
}

resource "aws_iam_role_policy" "ecs_task_policy" {
  name = "${var.service_name}-task-policy-${terraform.workspace}"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "*",
        Resource = "*"
      }
    ]
  })
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.service_name}-${terraform.workspace}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = var.service_name
      image     = var.image_url
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "SQS_URL", value = var.sqs_url } 
      ]
      secrets = [
        {
          name      = "TOKEN_PARAM"
          valueFrom = var.token_param_arn 
        }
      ]
    }
  ])
}

resource "aws_lb_target_group" "this" {
  name     = "${var.service_name}-tg-${terraform.workspace}"
  port     = var.container_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"
  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/health"      
    port                = "5000"         
    interval            = 30
    timeout             = 10            
    healthy_threshold   = 2
    unhealthy_threshold = 5
    matcher             = "200"
  }
}

resource "aws_ecs_service" "this" {
  name            = "${var.service_name}-${terraform.workspace}"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn  
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnets
    security_groups = var.security_groups
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = var.service_name
    container_port   = var.container_port
  }

  depends_on = [aws_iam_role_policy.ecs_task_policy]
}

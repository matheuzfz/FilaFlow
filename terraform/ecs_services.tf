# ==============================================================================
# ECS Task Definitions e Services (Fargate) - FilaFlow
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Backend Task Definition & Service (FastAPI)
# ------------------------------------------------------------------------------
resource "aws_ecs_task_definition" "backend" {
  family                   = "filaflow-backend-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "filaflow-backend"
      image     = "${aws_ecr_repository.repos["filaflow-backend"].repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "AWS_REGION"
          value = var.aws_region
        },
        {
          name  = "DYNAMODB_TABLE"
          value = aws_dynamodb_table.inventory.name
        }
      ]
    }
  ])

  tags = {
    Name = "filaflow-backend-task"
  }
}

resource "aws_ecs_service" "backend" {
  name            = "filaflow-backend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_1.id, aws_subnet.public_2.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  tags = {
    Name = "filaflow-backend-service"
  }
}

# ------------------------------------------------------------------------------
# 2. Frontend Task Definition & Service (React / Nginx)
# ------------------------------------------------------------------------------
resource "aws_ecs_task_definition" "frontend" {
  family                   = "filaflow-frontend-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "filaflow-frontend"
      image     = "${aws_ecr_repository.repos["filaflow-frontend"].repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])

  tags = {
    Name = "filaflow-frontend-task"
  }
}

resource "aws_ecs_service" "frontend" {
  name            = "filaflow-frontend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_1.id, aws_subnet.public_2.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  tags = {
    Name = "filaflow-frontend-service"
  }
}

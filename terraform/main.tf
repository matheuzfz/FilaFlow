# ==============================================================================
# Main Terraform Configuration - FilaFlow Infrastructure
# ==============================================================================

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Configuração do backend remoto no Amazon S3
  backend "s3" {
    bucket = "filaflow-terraform-state-274622205752"
    key    = "terraform/state.tfstate"
    region = "us-east-1"
  }
}

# Configuração do Provedor AWS
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "FilaFlow"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# ==============================================================================
# 1. Rede (VPC, Subnets Públicas e Internet Gateway)
# ==============================================================================

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# VPC simples para abrigar a infraestrutura do FilaFlow
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.app_name}-vpc"
  }
}

# Internet Gateway para fornecer acesso à internet pública
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.app_name}-igw"
  }
}

# Subnet Pública 1 (us-east-1a)
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.app_name}-public-subnet-1"
  }
}

# Subnet Pública 2 (us-east-1b)
resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.app_name}-public-subnet-2"
  }
}

# Tabela de Roteamento para a Subnet Pública
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.app_name}-public-rt"
  }
}

# Associação da Tabela de Roteamento à Subnet Pública 1
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

# Associação da Tabela de Roteamento à Subnet Pública 2
resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# Security Group para as tarefas e serviços do ECS
resource "aws_security_group" "ecs_sg" {
  name        = "${var.app_name}-ecs-sg"
  description = "Security Group para os containers ECS do FilaFlow (Frontend na porta 80 e Backend na porta 8000)"
  vpc_id      = aws_vpc.main.id

  # Ingress: Porta 80 para o Frontend (Node.js)
  ingress {
    description = "Permite trafego HTTP na porta 80 para o Frontend"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress: Porta 8000 para a API Backend (Python/FastAPI)
  ingress {
    description = "Permite trafego na porta 8000 para o Backend FastAPI"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress: Liberar todo o tráfego de saída
  egress {
    description = "Libera todo o trafego de saida"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-ecs-sg"
  }
}

# ==============================================================================
# 2. Banco de Dados (Amazon DynamoDB)
# ==============================================================================

# Tabela para gestão de inventário de filamentos
resource "aws_dynamodb_table" "inventory" {
  name         = "filaflow-inventory"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "filaflow-inventory"
  }
}

# ==============================================================================
# 3. Repositórios de Imagens (Amazon ECR)
# ==============================================================================

# Repositórios privados do ECR para Backend e Frontend
resource "aws_ecr_repository" "repos" {
  for_each = toset(["filaflow-backend", "filaflow-frontend"])

  name                 = each.value
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = each.value
  }
}

# Política de Ciclo de Vida para manter apenas as últimas 5 imagens em cada repositório
resource "aws_ecr_lifecycle_policy" "repo_policy" {
  for_each   = aws_ecr_repository.repos
  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Manter apenas as ultimas 5 imagens"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ==============================================================================
# 4. Orquestração de Containers (Amazon ECS & IAM)
# ==============================================================================

# Cluster ECS do FilaFlow
resource "aws_ecs_cluster" "main" {
  name = "filaflow-cluster"

  tags = {
    Name = "filaflow-cluster"
  }
}

# IAM Role para Execução de Tasks do ECS (ecsTaskExecutionRole)
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

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

  tags = {
    Name = "ecsTaskExecutionRole"
  }
}

# Anexo da política gerenciada AmazonECSTaskExecutionRolePolicy à Role de execução do ECS
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

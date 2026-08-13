# ==============================================================================
# Outputs Configuration - FilaFlow Infrastructure
# ==============================================================================

# Outputs de Rede
output "vpc_id" {
  description = "ID da VPC criada."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs das Subnets Públicas criadas."
  value       = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

output "ecs_security_group_id" {
  description = "ID do Security Group para os containers ECS."
  value       = aws_security_group.ecs_sg.id
}

# Outputs do Banco de Dados DynamoDB
output "dynamodb_table_name" {
  description = "Nome da tabela do DynamoDB."
  value       = aws_dynamodb_table.inventory.name
}

output "dynamodb_table_arn" {
  description = "ARN da tabela do DynamoDB."
  value       = aws_dynamodb_table.inventory.arn
}

# Outputs dos Repositórios ECR
output "ecr_backend_repository_url" {
  description = "URL do repositório ECR para o Backend."
  value       = aws_ecr_repository.repos["filaflow-backend"].repository_url
}

output "ecr_frontend_repository_url" {
  description = "URL do repositório ECR para o Frontend."
  value       = aws_ecr_repository.repos["filaflow-frontend"].repository_url
}

# Outputs do ECS & IAM
output "ecs_cluster_name" {
  description = "Nome do Cluster ECS."
  value       = aws_ecs_cluster.main.name
}

output "ecs_cluster_arn" {
  description = "ARN do Cluster ECS."
  value       = aws_ecs_cluster.main.arn
}

output "ecs_task_execution_role_arn" {
  description = "ARN da IAM Role de execução das tasks do ECS."
  value       = aws_iam_role.ecs_task_execution_role.arn
}

# Outputs dos Serviços ECS
output "ecs_backend_service_name" {
  description = "Nome do serviço ECS para o Backend."
  value       = aws_ecs_service.backend.name
}

output "ecs_frontend_service_name" {
  description = "Nome do serviço ECS para o Frontend."
  value       = aws_ecs_service.frontend.name
}

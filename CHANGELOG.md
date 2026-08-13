# Changelog

Todas as alterações notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [1.0.0] - 2026-08-12

### Added
- Infraestrutura inicial via Terraform (VPC, ECS Cluster, ECR Repositories, DynamoDB).
- Backend base em Python/FastAPI com boto3, Pydantic, rotas para gerenciamento de filamentos e testes unitários com pytest.
- Frontend base em Node.js/React (Vite, TailwindCSS) com formulário, listagem de filamentos, Dockerfile multi-stage e testes unitários com Vitest.
- Pipeline de CI/CD inteligente no GitHub Actions com filtro de diretórios (`dorny/paths-filter`), testes automatizados e build/push condicional de imagens no ECR.

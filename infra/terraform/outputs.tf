output "aws_region" {
  description = "AWS region used by this stack."
  value       = var.aws_region
}

output "aws_account_id" {
  description = "AWS account ID."
  value       = data.aws_caller_identity.current.account_id
}

output "eks_cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint."
  value       = module.eks.cluster_endpoint
}

output "ecr_repository_name" {
  description = "ECR repository name."
  value       = aws_ecr_repository.app.name
}

output "ecr_repository_url" {
  description = "ECR repository URL used by Docker push."
  value       = aws_ecr_repository.app.repository_url
}

output "github_actions_role_arn" {
  description = "Use this value as the GitHub Actions variable AWS_ROLE_TO_ASSUME."
  value       = aws_iam_role.github_actions.arn
}

output "rds_endpoint" {
  description = "RDS endpoint when create_rds is true."
  value       = try(aws_db_instance.postgres[0].endpoint, null)
}

output "rds_master_secret_arn" {
  description = "AWS Secrets Manager ARN containing the generated RDS master password when create_rds is true."
  value       = try(aws_db_instance.postgres[0].master_user_secret[0].secret_arn, null)
}

output "database_url_template" {
  description = "Template for DATABASE_URL. Replace password with the value from rds_master_secret_arn."
  value = var.create_rds ? format(
    "postgresql://%s:<password-from-secrets-manager>@%s/%s",
    var.db_username,
    try(aws_db_instance.postgres[0].endpoint, "rds-endpoint:5432"),
    var.db_name
  ) : null
}

output "github_actions_variables" {
  description = "Non-sensitive values to create under GitHub Actions repository Variables."
  value = {
    AWS_REGION         = var.aws_region
    AWS_ACCOUNT_ID     = data.aws_caller_identity.current.account_id
    AWS_ROLE_TO_ASSUME = aws_iam_role.github_actions.arn
    EKS_CLUSTER_NAME   = module.eks.cluster_name
    ECR_REPOSITORY     = aws_ecr_repository.app.name
  }
}

output "github_actions_secrets" {
  description = "Sensitive values to create under GitHub Actions repository Secrets."
  value = {
    DATABASE_URL_STAGING    = "Create manually from your staging PostgreSQL connection string."
    DATABASE_URL_PRODUCTION = "Create manually from your production PostgreSQL connection string."
  }
}

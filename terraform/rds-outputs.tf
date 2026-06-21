
output "db_endpoint" {
  description = "Database connection endpoint"
  value       = aws_db_instance.main.address
}

output "db_port" {
  description = "Database port"
  value       = 5432
}

output "db_secret_arn" {
  description = "Database password secret ARN"
  value       = aws_secretsmanager_secret.db_password.arn
}

output "db_database_url" {
  description = "Database application connection string"
  value       = "postgresql://dbadmin:${urlencode(random_password.db_password.result)}@${aws_db_instance.main.address}:5432/progressivedeliveryfastapidb1"
  sensitive   = true
}

output "redis_endpoint" {
  description = "Redis primary endpoint"
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "redis_port" {
  description = "Redis port"
  value       = 6379
}

output "redis_url" {
  description = "Redis application connection string"
  value       = "rediss://:${urlencode(random_password.redis_auth_token.result)}@${aws_elasticache_replication_group.main.primary_endpoint_address}:6379/0"
  sensitive   = true
}

output "redis_auth_token_secret_arn" {
  description = "Redis auth token secret ARN"
  value       = aws_secretsmanager_secret.redis_auth_token.arn
}

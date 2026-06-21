# ElastiCache Redis

# Redis Cache
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project_name}-redis"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name                   = "${var.project_name}-redis-subnet-group"
    Project                = var.project_name
    TerraPilotProject      = var.project_name
    TerraPilotResourceType = "elasticache-subnet-group"
    Environment            = var.environment
    ManagedBy              = "TerraPilot"
    CostSensitive          = "true"
  }
}

resource "aws_security_group" "redis" {
  name_prefix = "${var.project_name}-redis-"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name                   = "${var.project_name}-redis-sg"
    Project                = var.project_name
    TerraPilotProject      = var.project_name
    TerraPilotResourceType = "security-group"
    Environment            = var.environment
    ManagedBy              = "TerraPilot"
    CostSensitive          = "true"
  }
}

resource "aws_security_group_rule" "redis_ingress" {
  description       = "Allow Redis access from the VPC CIDR"
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  security_group_id = aws_security_group.redis.id
  cidr_blocks       = [aws_vpc.main.cidr_block]
}


resource "random_password" "redis_auth_token" {
  length  = 64
  special = false
}

resource "aws_secretsmanager_secret" "redis_auth_token" {
  name = "${var.project_name}-redis-auth-token"
  tags = {
    Name                   = "${var.project_name}-redis-auth-token"
    Project                = var.project_name
    TerraPilotProject      = var.project_name
    TerraPilotResourceType = "secrets-manager-secret"
    Environment            = var.environment
    ManagedBy              = "TerraPilot"
    CostSensitive          = "false"
  }
}

resource "aws_secretsmanager_secret_version" "redis_auth_token" {
  secret_id = aws_secretsmanager_secret.redis_auth_token.id
  secret_string = jsonencode({
    auth_token = random_password.redis_auth_token.result
    host       = aws_elasticache_replication_group.main.primary_endpoint_address
    port       = 6379
    redis_url  = "rediss://:${urlencode(random_password.redis_auth_token.result)}@${aws_elasticache_replication_group.main.primary_endpoint_address}:6379/0"
    REDIS_URL  = "rediss://:${urlencode(random_password.redis_auth_token.result)}@${aws_elasticache_replication_group.main.primary_endpoint_address}:6379/0"
  })
}

resource "aws_elasticache_replication_group" "main" {
  replication_group_id = "${var.project_name}-redis"
  description          = "Redis cluster for ${var.project_name}"

  engine             = "redis"
  engine_version     = "7.0"
  node_type          = "cache.t3.micro"
  num_cache_clusters = 1

  port               = 6379
  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = [aws_security_group.redis.id]

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auth_token                 = random_password.redis_auth_token.result
  automatic_failover_enabled = false
  multi_az_enabled           = false

  snapshot_retention_limit   = 1
  maintenance_window         = "Mon:05:00-Mon:06:00"
  auto_minor_version_upgrade = true

  tags = {
    Name                   = "${var.project_name}-redis"
    Project                = var.project_name
    TerraPilotProject      = var.project_name
    TerraPilotResourceType = "elasticache-replication-group"
    Environment            = var.environment
    ManagedBy              = "TerraPilot"
    CostSensitive          = "true"
  }
}

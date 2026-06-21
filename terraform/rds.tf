# RDS Databases

# Database: progressivedeliveryfastapidb1 (postgres)
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name                   = "${var.project_name}-db-subnet-group"
    Project                = var.project_name
    TerraPilotProject      = var.project_name
    TerraPilotResourceType = "db-subnet-group"
    Environment            = var.environment
    ManagedBy              = "TerraPilot"
    CostSensitive          = "true"
  }
}

resource "aws_security_group" "db" {
  name_prefix = "${var.project_name}-db-"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name                   = "${var.project_name}-db-sg"
    Project                = var.project_name
    TerraPilotProject      = var.project_name
    TerraPilotResourceType = "security-group"
    Environment            = var.environment
    ManagedBy              = "TerraPilot"
    CostSensitive          = "true"
  }
}

resource "aws_security_group_rule" "db_ingress" {
  description       = "Allow database access from the VPC CIDR"
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.db.id
  cidr_blocks       = [aws_vpc.main.cidr_block]
}


resource "aws_secretsmanager_secret" "db_password" {
  name = "${var.project_name}-db-password"
  tags = {
    Name                   = "${var.project_name}-db-password"
    Project                = var.project_name
    TerraPilotProject      = var.project_name
    TerraPilotResourceType = "secrets-manager-secret"
    Environment            = var.environment
    ManagedBy              = "TerraPilot"
    CostSensitive          = "false"
  }
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username     = "dbadmin"
    password     = random_password.db_password.result
    host         = aws_db_instance.main.address
    port         = 5432
    dbname       = "progressivedeliveryfastapidb1"
    database_url = "postgresql://dbadmin:${urlencode(random_password.db_password.result)}@${aws_db_instance.main.address}:5432/progressivedeliveryfastapidb1"
    DATABASE_URL = "postgresql://dbadmin:${urlencode(random_password.db_password.result)}@${aws_db_instance.main.address}:5432/progressivedeliveryfastapidb1"
  })
}

resource "random_password" "db_password" {
  length           = 32
  special          = true
  override_special = "!#$%^&*()"
}

resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-db"

  engine                = "postgres"
  engine_version        = "16.4"
  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  max_allocated_storage = 30
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = "progressivedeliveryfastapidb1"
  username = "dbadmin"
  password = random_password.db_password.result
  port     = 5432

  multi_az               = false
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]

  backup_retention_period    = 1
  backup_window              = "03:00-04:00"
  maintenance_window         = "Mon:04:00-Mon:05:00"
  auto_minor_version_upgrade = true
  skip_final_snapshot        = true
  final_snapshot_identifier  = null
  deletion_protection        = false

  performance_insights_enabled = false
  monitoring_interval          = 0

  enabled_cloudwatch_logs_exports     = []
  iam_database_authentication_enabled = false

  tags = {
    Name                   = "${var.project_name}-db"
    Project                = var.project_name
    TerraPilotProject      = var.project_name
    TerraPilotResourceType = "rds-instance"
    Environment            = var.environment
    ManagedBy              = "TerraPilot"
    CostSensitive          = "true"
  }
}

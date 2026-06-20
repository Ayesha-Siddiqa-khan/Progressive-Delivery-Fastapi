resource "aws_security_group" "rds" {
  count = var.create_rds ? 1 : 0

  name        = "${var.project_name}-${var.environment}-rds"
  description = "Allow PostgreSQL from EKS worker nodes."
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "PostgreSQL from EKS nodes"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "postgres" {
  count = var.create_rds ? 1 : 0

  name       = "${var.project_name}-${var.environment}-postgres"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_db_instance" "postgres" {
  count = var.create_rds ? 1 : 0

  identifier = "${var.project_name}-${var.environment}-postgres"

  engine         = "postgres"
  engine_version = "16"
  instance_class = var.db_instance_class

  allocated_storage = var.db_allocated_storage
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username

  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.postgres[0].name
  vpc_security_group_ids = [aws_security_group.rds[0].id]

  publicly_accessible     = false
  deletion_protection     = var.db_deletion_protection
  skip_final_snapshot     = var.db_skip_final_snapshot
  apply_immediately       = true
  multi_az                = false
  backup_retention_period = 7
}

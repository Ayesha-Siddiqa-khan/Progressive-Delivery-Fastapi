variable "aws_region" {
  description = "AWS region for EKS, ECR, and optional RDS."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used in resource names and tags."
  type        = string
  default     = "progressive-delivery-fastapi"
}

variable "environment" {
  description = "Infrastructure environment name."
  type        = string
  default     = "dev"
}

variable "cluster_name" {
  description = "Optional EKS cluster name. If null, project_name-environment is used."
  type        = string
  default     = null
}

variable "eks_cluster_version" {
  description = "EKS Kubernetes version. Adjust if your AWS region supports a newer version."
  type        = string
  default     = "1.32"
}

variable "github_repository" {
  description = "GitHub repository allowed to assume the deployment role, for example username/progressive-delivery-fastapi."
  type        = string
}

variable "github_branch" {
  description = "GitHub branch allowed to deploy through OIDC."
  type        = string
  default     = "main"
}

variable "cluster_admin_principal_arns" {
  description = "IAM user or role ARNs that should have Kubernetes admin access to the EKS cluster. Do not use the AWS root principal here."
  type        = list(string)
  default     = []
}

variable "vpc_cidr" {
  description = "CIDR range for the VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "az_count" {
  description = "Number of availability zones to use."
  type        = number
  default     = 2
}

variable "enable_nat_gateway" {
  description = "Whether to create NAT Gateway resources for private subnets. NAT Gateway has hourly and data costs."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Whether to use one NAT Gateway instead of one per availability zone. Cheaper for portfolio demos."
  type        = bool
  default     = true
}

variable "node_instance_types" {
  description = "EC2 instance types for EKS managed node group."
  type        = list(string)
  default     = ["t3.small"]
}

variable "node_min_size" {
  description = "Minimum EKS worker nodes."
  type        = number
  default     = 1
}

variable "node_desired_size" {
  description = "Desired EKS worker nodes."
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum EKS worker nodes."
  type        = number
  default     = 2
}

variable "ecr_repository_name" {
  description = "ECR repository used by GitHub Actions."
  type        = string
  default     = "progressive-delivery-fastapi"
}

variable "create_rds" {
  description = "Whether to create an RDS PostgreSQL instance. Keep false if you already have RDS."
  type        = bool
  default     = false
}

variable "db_name" {
  description = "Initial PostgreSQL database name."
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "PostgreSQL master username. Password is managed by AWS Secrets Manager."
  type        = string
  default     = "appuser"
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t4g.micro"
}

variable "db_allocated_storage" {
  description = "RDS allocated storage in GB."
  type        = number
  default     = 20
}

variable "db_deletion_protection" {
  description = "Enable deletion protection for RDS. Use true for serious environments."
  type        = bool
  default     = false
}

variable "db_skip_final_snapshot" {
  description = "Skip final DB snapshot on destroy. Convenient for demos, unsafe for production."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Extra tags applied to AWS resources."
  type        = map(string)
  default     = {}
}

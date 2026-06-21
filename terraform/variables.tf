variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "progressive-delivery-fastapi"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "ami_source" {
  description = "AMI source: amazon-linux-ssm, ubuntu-ami, debian-ami, rhel-ami, or custom"
  type        = string
  default     = "ubuntu-ami"

  validation {
    condition     = contains(["amazon-linux-ssm", "ubuntu-ami", "debian-ami", "rhel-ami", "custom"], var.ami_source)
    error_message = "ami_source must be amazon-linux-ssm, ubuntu-ami, debian-ami, rhel-ami, or custom."
  }
}

variable "ami_architecture" {
  description = "AMI architecture"
  type        = string
  default     = "x86_64"

  validation {
    condition     = contains(["x86_64", "arm64"], var.ami_architecture)
    error_message = "ami_architecture must be x86_64 or arm64."
  }
}

variable "custom_ami_id" {
  description = "Custom AMI ID to use for EC2 instances"
  type        = string
  default     = ""

  validation {
    condition     = var.custom_ami_id == "" || startswith(var.custom_ami_id, "ami-")
    error_message = "custom_ami_id must be empty or start with ami-."
  }
}

variable "ubuntu_ami_name_pattern" {
  description = "Ubuntu AMI name filter pattern"
  type        = string
  default     = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
}

variable "debian_ami_name_pattern" {
  description = "Debian AMI name filter pattern"
  type        = string
  default     = "debian-12-amd64-daily"
}

variable "rhel_ami_name_pattern" {
  description = "RHEL / CentOS / Rocky AMI name filter pattern"
  type        = string
  default     = "RHEL-9.*-x86_64-Hourly"
}

variable "ami_ssm_parameter_name" {
  description = "SSM parameter name for Amazon Linux AMI"
  type        = string
  default     = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

variable "ec2_security_group_attachment_mode" {
  description = "Security group attachment mode for EC2: generated, existing, mixed, default, or none"
  type        = string
  default     = "generated"

  validation {
    condition     = contains(["generated", "existing", "mixed", "default", "none"], var.ec2_security_group_attachment_mode)
    error_message = "ec2_security_group_attachment_mode must be generated, existing, mixed, default, or none."
  }
}

variable "attach_http_security_group_to_ec2" {
  description = "Attach generated HTTP security group to EC2 instances"
  type        = bool
  default     = true
}

variable "attach_https_security_group_to_ec2" {
  description = "Attach generated HTTPS security group to EC2 instances"
  type        = bool
  default     = true
}

variable "attach_ssh_security_group_to_ec2" {
  description = "Attach generated SSH security group to EC2 instances"
  type        = bool
  default     = true
}

variable "security_group_quota_per_network_interface" {
  description = "AWS security group quota per network interface. Default AWS quota is 5 and adjustable up to 16."
  type        = number
  default     = 5

  validation {
    condition     = var.security_group_quota_per_network_interface >= 1 && var.security_group_quota_per_network_interface <= 16
    error_message = "security_group_quota_per_network_interface must be between 1 and 16."
  }
}

variable "existing_security_group_ids" {
  description = "Existing security group IDs to attach to EC2 instances"
  type        = list(string)
  default     = []
}

variable "use_default_security_group_for_ec2" {
  description = "Use the VPC default security group for EC2 instances"
  type        = bool
  default     = false
}

variable "enable_ssh_security_group" {
  description = "Create generated SSH security group"
  type        = bool
  default     = true
}

variable "enable_k8s_api_security_group" {
  description = "Create generated Kubernetes API Server security group"
  type        = bool
  default     = true
}

variable "enable_etcd_security_group" {
  description = "Create generated etcd security group"
  type        = bool
  default     = true
}

variable "enable_kubelet_security_group" {
  description = "Create generated Kubelet API security group"
  type        = bool
  default     = true
}

variable "enable_calico_vxlan_security_group" {
  description = "Create generated Calico VXLAN security group"
  type        = bool
  default     = true
}

variable "enable_calico_typha_security_group" {
  description = "Create generated Calico Typha security group"
  type        = bool
  default     = true
}

variable "enable_calico_bgp_security_group" {
  description = "Create generated Calico BGP security group"
  type        = bool
  default     = true
}

variable "enable_k8s_scheduler_security_group" {
  description = "Create generated Kube Scheduler security group"
  type        = bool
  default     = true
}

variable "enable_k8s_ctrl_mgr_security_group" {
  description = "Create generated Kube Controller Manager security group"
  type        = bool
  default     = true
}

variable "enable_nodeport_security_group" {
  description = "Create generated NodePort Services security group"
  type        = bool
  default     = true
}

variable "enable_kagent_ui_8080_security_group" {
  description = "Create generated kagent UI Port 8080 security group"
  type        = bool
  default     = true
}

variable "enable_dns_tcp_security_group" {
  description = "Create generated DNS (TCP) security group"
  type        = bool
  default     = true
}

variable "enable_dns_udp_security_group" {
  description = "Create generated DNS (UDP) security group"
  type        = bool
  default     = true
}

variable "enable_http_security_group" {
  description = "Create generated HTTP security group"
  type        = bool
  default     = true
}

variable "enable_https_security_group" {
  description = "Create generated HTTPS security group"
  type        = bool
  default     = true
}

variable "enable_postgres_security_group" {
  description = "Create generated PostgreSQL security group"
  type        = bool
  default     = true
}

variable "enable_redis_security_group" {
  description = "Create generated Redis security group"
  type        = bool
  default     = true
}

variable "enable_mysql_security_group" {
  description = "Create generated MySQL security group"
  type        = bool
  default     = true
}

variable "key_pair_mode" {
  description = "EC2 key pair mode: none, existing, or create"
  type        = string
  default     = "existing"

  validation {
    condition     = contains(["none", "existing", "create"], var.key_pair_mode)
    error_message = "key_pair_mode must be one of: none, existing, create."
  }
}

variable "existing_key_pair_name" {
  description = "Existing EC2 key pair name"
  type        = string
  default     = "my-key"
}

variable "key_pair_name" {
  description = "New EC2 key pair name"
  type        = string
  default     = "my-key"
}

variable "public_key" {
  description = "Public SSH key content for creating a new EC2 key pair"
  type        = string
  default     = ""
  sensitive   = true
}

variable "kagent_enabled" {
  description = "Install kagent and create the Bedrock Kubernetes agent on the self-managed control plane"
  type        = bool
  default     = false
}

variable "bedrock_region" {
  description = "AWS Bedrock region for kagent"
  type        = string
  default     = "us-east-1"
}

variable "bedrock_model_id" {
  description = "AWS Bedrock model ID for kagent"
  type        = string
  default     = "amazon.nova-micro-v1:0"
}

variable "kagent_provider" {
  description = "AI provider for kagent (aws_bedrock, openai, anthropic, gemini)"
  type        = string
  default     = "aws_bedrock"
}

variable "kagent_aws_credential_mode" {
  description = "AWS credential mode for kagent Bedrock access (ec2_instance_role or kubernetes_secret)"
  type        = string
  default     = "ec2_instance_role"
}

variable "enable_kagent_bedrock_iam_policy" {
  description = "Attach inline Bedrock invoke permissions for kagent when using EC2 instance role credentials"
  type        = bool
  default     = false
}

variable "model_id" {
  description = "Model ID for non-Bedrock providers"
  type        = string
  default     = "amazon.nova-micro-v1:0"
}

variable "openai_api_key" {
  description = "OpenAI API key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "anthropic_api_key" {
  description = "Anthropic API key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "gemini_api_key" {
  description = "Google Gemini API key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ollama_endpoint" {
  description = "Ollama API endpoint for kagent"
  type        = string
  default     = "http://localhost:11434"
}

variable "custom_provider_name" {
  description = "Custom kagent provider name"
  type        = string
  default     = "custom"
}

variable "custom_provider_endpoint" {
  description = "Custom kagent provider endpoint"
  type        = string
  default     = ""
}

variable "custom_provider_api_key" {
  description = "Custom kagent provider API key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
  default     = "progressive-delivery-fastapi"
}

variable "ecr_image_tag_mutability" {
  description = "ECR image tag mutability"
  type        = string
  default     = "IMMUTABLE"
}

variable "ecr_scan_on_push" {
  description = "Whether ECR scans container images after push"
  type        = bool
  default     = false
}

variable "ecr_lifecycle_policy_enabled" {
  description = "Whether to create an ECR lifecycle policy"
  type        = bool
  default     = false
}

variable "github_repository" {
  description = "GitHub repository allowed to assume the generated OIDC role, in OWNER/REPO format"
  type        = string
  default     = "<OWNER>/<REPO>"
}

variable "github_branch" {
  description = "GitHub branch allowed to assume the generated OIDC role"
  type        = string
  default     = "main"
}

variable "github_oidc_audience" {
  description = "GitHub Actions OIDC audience for AWS STS"
  type        = string
  default     = "sts.amazonaws.com"
}

variable "github_oidc_thumbprint_list" {
  description = "GitHub Actions OIDC provider thumbprints"
  type        = list(string)
  default     = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

variable "ec2_instances" {
  description = "List of EC2 instance configurations"
  type = list(object({
    name                = string
    instance_type       = string
    quantity            = number
    subnet_type         = string
    associate_public_ip = bool
    root_volume_size    = number
    root_volume_type    = string
    encrypt_root_volume = bool
    role                = string
  }))
  default = [
    {
      "name" : "c7i-flex-large",
      "instance_type" : "c7i-flex.large",
      "quantity" : 1,
      "subnet_type" : "public",
      "associate_public_ip" : true,
      "root_volume_size" : 15,
      "root_volume_type" : "gp3",
      "encrypt_root_volume" : false,
      "role" : "kubernetes-master"
    },
    {
      "name" : "t3-micro",
      "instance_type" : "t3.micro",
      "quantity" : 1,
      "subnet_type" : "public",
      "associate_public_ip" : true,
      "root_volume_size" : 10,
      "root_volume_type" : "gp3",
      "encrypt_root_volume" : false,
      "role" : "kubernetes-worker"
    }
  ]
}

variable "iam_users" {
  description = "IAM users to create"
  type = list(object({
    username             = string
    console_access       = bool
    programmatic_access  = bool
    force_password_reset = bool
    mfa_recommended      = bool
    groups               = list(string)
    attached_policies    = list(string)
    tags                 = map(string)
  }))
  default = []
}

variable "iam_groups" {
  description = "IAM groups to create"
  type = list(object({
    name              = string
    description       = optional(string)
    attached_policies = list(string)
    users             = list(string)
  }))
  default = []
}

variable "iam_roles" {
  description = "IAM roles to create"
  type = list(object({
    name              = string
    type              = string
    trusted_entity    = string
    attached_policies = list(string)
    inline_policies   = list(string)
    tags              = map(string)
  }))
  default = []
}

variable "databases" {
  description = "RDS database configurations"
  type = list(object({
    engine                       = string
    engine_version               = string
    instance_class               = string
    allocated_storage            = number
    max_allocated_storage        = number
    storage_type                 = string
    storage_encrypted            = bool
    multi_az                     = bool
    publicly_accessible          = bool
    db_name                      = string
    username                     = string
    port                         = number
    backup_retention_period      = number
    backup_window                = string
    maintenance_window           = string
    skip_final_snapshot          = bool
    deletion_protection          = bool
    performance_insights_enabled = bool
    monitoring_interval          = number
    auto_minor_version_upgrade   = bool
    subnet_type                  = string
    cloudwatch_logs_export       = list(string)
    read_replicas                = number
    iam_database_authentication  = bool
  }))
  default = [
    {
      "engine" : "postgres",
      "engine_version" : "16.4",
      "instance_class" : "db.t3.micro",
      "allocated_storage" : 20,
      "max_allocated_storage" : 30,
      "storage_type" : "gp3",
      "storage_encrypted" : true,
      "multi_az" : false,
      "publicly_accessible" : false,
      "db_name" : "progressivedeliveryfastapidb1",
      "username" : "dbadmin",
      "port" : 5432,
      "backup_retention_period" : 1,
      "backup_window" : "03:00-04:00",
      "maintenance_window" : "Mon:04:00-Mon:05:00",
      "skip_final_snapshot" : true,
      "deletion_protection" : false,
      "performance_insights_enabled" : false,
      "monitoring_interval" : 0,
      "auto_minor_version_upgrade" : true,
      "subnet_type" : "private",
      "cloudwatch_logs_export" : [],
      "read_replicas" : 0,
      "iam_database_authentication" : false
    }
  ]
}

variable "redis_caches" {
  description = "ElastiCache Redis configurations"
  type = list(object({
    engine_version             = string
    node_type                  = string
    num_cache_nodes            = number
    num_replicas_per_cluster   = number
    multi_az                   = bool
    encryption_at_rest         = bool
    encryption_in_transit      = bool
    auth_token_enabled         = bool
    port                       = number
    maintenance_window         = string
    snapshot_retention_limit   = number
    auto_minor_version_upgrade = bool
    subnet_type                = string
    automatic_failover         = bool
    cluster_mode               = bool
  }))
  default = [
    {
      "engine_version" : "7.0",
      "node_type" : "cache.t3.micro",
      "num_cache_nodes" : 1,
      "num_replicas_per_cluster" : 0,
      "multi_az" : false,
      "encryption_at_rest" : true,
      "encryption_in_transit" : true,
      "auth_token_enabled" : true,
      "port" : 6379,
      "maintenance_window" : "Mon:05:00-Mon:06:00",
      "snapshot_retention_limit" : 1,
      "auto_minor_version_upgrade" : true,
      "subnet_type" : "private",
      "automatic_failover" : false,
      "cluster_mode" : false
    }
  ]
}

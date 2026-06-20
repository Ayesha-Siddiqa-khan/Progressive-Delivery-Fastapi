locals {
  cluster_name = coalesce(var.cluster_name, "${var.project_name}-${var.environment}")

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags
  )

  availability_zones = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  public_subnets = [
    for index in range(var.az_count) : cidrsubnet(var.vpc_cidr, 4, index)
  ]

  private_subnets = [
    for index in range(var.az_count) : cidrsubnet(var.vpc_cidr, 4, index + var.az_count)
  ]
}

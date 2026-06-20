module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.cluster_name
  cluster_version = var.eks_cluster_version

  cluster_endpoint_public_access = true

  enable_cluster_creator_admin_permissions = true
  enable_irsa                              = true

  # The project name is long, and AWS IAM role name_prefix has a 38 character
  # limit. Fixed role names avoid that prefix limit while keeping readable names.
  iam_role_use_name_prefix = false
  iam_role_name            = "${local.cluster_name}-cluster"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  eks_managed_node_group_defaults = {
    instance_types           = var.node_instance_types
    iam_role_use_name_prefix = false
    iam_role_name            = "${local.cluster_name}-node"

    iam_role_additional_policies = {
      AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    }
  }

  eks_managed_node_groups = {
    default = {
      name            = "${local.cluster_name}-default"
      use_name_prefix = false

      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size
    }
  }

  access_entries = merge(
    {
      github_actions = {
        principal_arn = aws_iam_role.github_actions.arn

        policy_associations = {
          cluster_admin = {
            policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
            access_scope = {
              type = "cluster"
            }
          }
        }
      }
    },
    {
      for index, principal_arn in var.cluster_admin_principal_arns :
      "cluster_admin_${index}" => {
        principal_arn = principal_arn

        policy_associations = {
          cluster_admin = {
            policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
            access_scope = {
              type = "cluster"
            }
          }
        }
      }
    }
  )
}

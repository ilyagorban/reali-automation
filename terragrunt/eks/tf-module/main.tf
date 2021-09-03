# fix values of example in https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/managed_node_groups

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

data "aws_availability_zones" "available" {
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = "1.21"
  subnets         = var.subnets

  tags = var.tags

  vpc_id = var.vpc_id

  node_groups_defaults = {
    disk_size = 10
  }

  node_groups = {
    argo = {
      desired_capacity = 1
      max_capacity     = 1
      min_capacity     = 1

      instance_types = var.argo_instance_types
      capacity_type  = "SPOT"
      k8s_labels = {
        Environment = var.env_name
      }
      additional_tags = var.tags
      taints = [
        {
          key = "CriticalAddonsOnly"
          value = "true"
          effect = "NO_SCHEDULE"
        }
      ]
    }
    application = {
      desired_capacity = 1
      max_capacity     = 1
      min_capacity     = 1

      instance_types = var.application_instance_types
      capacity_type  = "SPOT"
      k8s_labels = {
        Environment = var.env_name
      }
      additional_tags = var.tags
      taints = [
        {
          key    = "dedicated"
          value  = "application"
          effect = "NO_SCHEDULE"
        }
      ]
    }
  }

  map_roles    = var.map_roles
  map_users    = var.map_users
}

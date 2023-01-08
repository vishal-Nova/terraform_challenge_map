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
}


provider "helm" {
  kubernetes {
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    host                   = data.aws_eks_cluster.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}
#module "naming" {
#  application = var.application
#  common_tags = var.common_tags
#  component   = var.component
#  env         = var.env_name
#  project     = var.project_name
#  region      = var.aws_region
#  role        = var.role
#}

module "eks" {
  source                      = "terraform-aws-modules/eks/aws"
  version                     = "14.0.0"
  cluster_name                = var.cluster_name
  cluster_version             = var.cluster_version
  map_roles                   = var.map_roles
  map_users                   = var.map_users
  subnets                     = var.subnet_id
  tags                        = var.common_tags
  vpc_id                      = var.vpc_id
  manage_aws_auth             = true
  enable_irsa                 = true
  workers_additional_policies = [aws_iam_policy.eks_worker_policy.arn]

  node_groups = {
    worker = {
      name           = var.nodegroup_name
      Name           = var.nodegroup_name
      instance_types = [var.instance_type]
      subnets        = var.subnet_id
      key_name       = var.key_name

      desired_capacity = var.desired_capacity
      max_capacity     = var.max_capacity
      min_capacity     = var.min_capacity
    }
  }

}

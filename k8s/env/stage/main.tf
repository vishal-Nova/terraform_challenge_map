provider "aws" {
  region  = "us-east-2"
}

terraform {
  backend "s3" {
    bucket         = "stage-terraform-state"
    key            = "stage.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "terraform_locks"
  }
}

locals {
  tags = {
    Project     = upper(var.project_name)
    application = "k8s"
    component   = "k8s-infrastructure"
    env         = lower(var.env_name)
  }
  common_tag = merge(var.common_tags, local.tags)
}


module "eks" {
  source                  = "../../modules/local/eks/"
  cluster_name            = "devops-eks-cluster"
  cluster_version         = "1.24"
  nodegroup_name          = "devops-nodegroup"
  worker_name             = "devops-worker-eks_asg"
  vpc_id                  = "vpc-487be721"
  role                    = "eksClusterRole"
  subnet_id               = ["subnet-53da1f1e","subnet-43ddbe2a","subnet-3b9a3140"]
  application             = "k8s"
  component               = "infrastructure"
  env_name                = var.env_name
  aws_region              = "us-east-1"
  project_name            = var.project_name
  common_tags             = local.common_tag
  route53_hosted_zone_ids = "Z05648352M7ORV2RQX7Z6"
  account_id              = "527929793569"
  key_name                = "testing"
  instance_type           = "t3.small"
  desired_capacity        = 2
  max_capacity            = 2
  min_capacity            = 2

}


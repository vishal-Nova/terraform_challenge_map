variable "aws_region" {
  description = "The AWS region to deploy to (e.g. us-east-1)."
}
variable "vpc_id" {
  description = "The AWS VPCID in which eks cluster get launched"
}

variable "key_name" {
  description = "SSH key name for EC2 instances in nodegroup"
}

variable "application" {
  description = "Application name"
}

variable "common_tags" {
  description = "set of common tags"
}

variable "cluster_name" {
  description = "eks cluster name"
}

variable "role" {
  description = "Project role name"

}
variable "cluster_version" {
  description = "Kubernetes version to use for EKS cluster."

}

variable "subnet_id" {
  description = "List of subnets for eks cluster"
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  default = [
    {
      rolearn  = "arn:aws:iam::<account_id>:role/Admins"
      username = "Admins"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::<account-id>:role/<normal_user>"
      username = "Admins"
      groups   = ["system:masters"]
    },
  ]
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  default = [
    {
      userarn  = "arn:aws:iam::<account_id>:user/Terraform"
      username = "Terraform"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::<account-id>:user/bitbucket-build"
      username = "bitbucket-build"
      groups   = ["system:masters"]
    },
  ]
}

variable route53_hosted_zone_ids {
  description = "Route53 hosted zoneid"

}

variable "datadog_api_key" {
  description = "Datadog API KEY"

}

variable "instance_type" {
  description = "Nodegroup instance type"
}

variable "desired_capacity" {
  description = "Desired capacity of aws servers in eks cluster"

}

variable "max_capacity" {
  description = "Maximum no of instances in eks cluster"

}

variable "min_capacity" {
  description = "Minimum no of instances in eks cluster"

}

variable "account_id" {
  description = "aws account id"
}

variable "usr_session" {
  description = "Dynamodb user"


}

variable "usr_adv_mapper" {
  description = "Dynamodb user "

}

variable "env_name" {
  description = "Environment name"
}

variable "nodegroup_name" {
  description = "EKS nodegroup name"
}

variable "project_name" {
  description = "project name"

}

variable "worker_name" {
  description = "nodegroup worker name"
}

variable "component" {
  description = "Component name"
}


locals {
  owner_name              = "${module.eks.cluster_id}-${var.project_name}-external-dns"
  dynamodb_session_arn    = "arn:aws:dynamodb:us-east-1:${var.account_id}:table/${var.usr_session}"
  dynamodb_adv_mapper_arn = "arn:aws:dynamodb:us-east-1:${var.account_id}:table/${var.usr_adv_mapper}"

}


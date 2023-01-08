#ALB ingress controller

resource "helm_release" "alb_ingress_controller" {
  name          = "alb-ingress-controller"
  repository    = "https://charts.helm.sh/incubator"
  chart         = "aws-alb-ingress-controller"
  namespace     = "kube-system"
  recreate_pods = true
  set {
    name  = "clusterName"
    value = var.cluster_name
  }
  set {
    name  = "awsRegion"
    value = var.aws_region
  }
  set {
    name  = "awsVpcID"
    value = var.vpc_id
  }

  set {
    name  = "scope.watchNamespace"
    value = ""
  }
  set {
    name  = "scope.singleNamespace"
    value = false
  }
  set {
    name  = "rbac.create"
    value = true
  }
  set {
    name  = "rbac.serviceAccount.create"
    value = true
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.alb_ingress_controller.arn
  }
}

#External DNS controller
resource "helm_release" "external_dns" {
  chart         = "external-dns"
  name          = "external-dns"
  namespace     = "kube-system"
  repository    = "https://charts.bitnami.com/bitnami"
  recreate_pods = true

  set {
    name  = "aws.region"
    value = var.aws_region
  }

  set {
    name  = "rbac.create"
    value = true
  }

  set {
    name  = "serviceAccount.create"
    value = true
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.external_dns.arn
  }

  set {
    name  = "provider"
    value = "aws"
  }

  set {
    name  = "logLevel"
    value = "info"
  }

  set {
    name  = "logFormat"
    value = "text"
  }
  set {
    name  = "aws.zoneType"
    value = "private"
  }
  set {
    name  = "aws.txtOwnerId"
    value = local.owner_name
  }
  set {
    name  = "zoneIDFilter"
    value = var.route53_hosted_zone_ids
  }
}

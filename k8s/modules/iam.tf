data "aws_iam_policy_document" "oidc_assume_policy_control" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringLike"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:*"]
    }

    principals {
      identifiers = [module.eks.oidc_provider_arn]
      type        = "Federated"
    }
  }
}


data "aws_iam_policy_document" "external_dns" {
  statement {
    actions   = ["route53:ChangeResourceRecordSets"]
    resources = formatlist("arn:aws:route53:::hostedzone/%s", var.route53_hosted_zone_ids)
  }
  statement {

    actions   = ["route53:ListHostedZones", "route53:ListResourceRecordSets"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "external_dns" {
  name               = "${module.eks.cluster_id}-external-dns"
  assume_role_policy = data.aws_iam_policy_document.oidc_assume_policy_control.json
}

resource "aws_iam_role_policy" "external_dns" {
  name   = "${module.eks.cluster_id}-external-dns"
  policy = data.aws_iam_policy_document.external_dns.json
  role   = aws_iam_role.external_dns.id
}

data "aws_iam_policy_document" "alb_ingress_controller" {
  # ref. https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/iam-policy.json

  statement {
    actions = [
      "acm:DescribeCertificate",
      "acm:ListCertificates",
      "acm:GetCertificate"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:DeleteSecurityGroup",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVpcs",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifyNetworkInterfaceAttribute",
      "ec2:RevokeSecurityGroupIngress"
    ]
    resources = ["*"]

  }
  statement {
    actions = [
      "elasticloadbalancing:AddListenerCertificates",
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DeleteRule",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:DescribeListenerCertificates",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeSSLPolicies",
      "elasticloadbalancing:DescribeTags",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:ModifyRule",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:RemoveListenerCertificates",
      "elasticloadbalancing:RemoveTags",
      "elasticloadbalancing:SetIpAddressType",
      "elasticloadbalancing:SetSecurityGroups",
      "elasticloadbalancing:SetSubnets",
      "elasticloadbalancing:SetWebACL"
    ]
    resources = ["*"]

  }
  statement {
    actions = [
      "iam:CreateServiceLinkedRole",
      "iam:GetServerCertificate",
      "iam:ListServerCertificates"
    ]
    resources = ["*"]
  }
  statement {
    actions   = ["cognito-idp:DescribeUserPoolClient"]
    resources = ["*"]
  }
  statement {
    actions = [
      "waf-regional:GetWebACLForResource",
      "waf-regional:GetWebACL",
      "waf-regional:AssociateWebACL",
      "waf-regional:DisassociateWebACL",
      "waf:GetWebACL",
      "wafv2:GetWebACLForResource"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "tag:GetResources",
      "tag:TagResources"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "alb_ingress_controller" {
  policy = data.aws_iam_policy_document.alb_ingress_controller.json
  role   = aws_iam_role.alb_ingress_controller.id
}

resource "aws_iam_role" "alb_ingress_controller" {
  name               = "${module.eks.cluster_id}-alb-ingress-controller"
  assume_role_policy = data.aws_iam_policy_document.oidc_assume_policy_control.json
}


data "aws_iam_policy_document" "eks_worker_policy" {
  statement {
    actions   = ["sqs:*"]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    actions = [
      "dynamodb:*",
      "dax:*",
      "application-autoscaling:DeleteScalingPolicy",
      "application-autoscaling:DeregisterScalableTarget",
      "application-autoscaling:DescribeScalableTargets",
      "application-autoscaling:DescribeScalingActivities",
      "application-autoscaling:DescribeScalingPolicies",
      "application-autoscaling:PutScalingPolicy",
      "application-autoscaling:RegisterScalableTarget",
      "cloudwatch:DeleteAlarms",
      "cloudwatch:DescribeAlarmHistory",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:DescribeAlarmsForMetric",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:GetMetricData",
      "datapipeline:ActivatePipeline",
      "datapipeline:CreatePipeline",
      "datapipeline:DeletePipeline",
      "datapipeline:DescribeObjects",
      "datapipeline:DescribePipelines",
      "datapipeline:GetPipelineDefinition",
      "datapipeline:ListPipelines",
      "datapipeline:PutPipelineDefinition",
      "datapipeline:QueryObjects",
      "ec2:DescribeVpcs",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "iam:GetRole",
      "iam:ListRoles",
      "kms:DescribeKey",
      "kms:ListAliases",
      "sns:CreateTopic",
      "sns:DeleteTopic",
      "sns:ListSubscriptions",
      "sns:ListSubscriptionsByTopic",
      "sns:ListTopics",
      "sns:Subscribe",
      "sns:Unsubscribe",
      "sns:SetTopicAttributes",
      "lambda:CreateFunction",
      "lambda:ListFunctions",
      "lambda:ListEventSourceMappings",
      "lambda:CreateEventSourceMapping",
      "lambda:DeleteEventSourceMapping",
      "lambda:GetFunctionConfiguration",
      "lambda:DeleteFunction",
      "resource-groups:ListGroups",
      "resource-groups:ListGroupResources",
      "resource-groups:GetGroup",
      "resource-groups:GetGroupQuery",
      "resource-groups:DeleteGroup",
      "resource-groups:CreateGroup",
      "tag:GetResources",
      "kinesis:ListStreams",
      "kinesis:DescribeStream",
      "kinesis:DescribeStreamSummary"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions   = ["cloudwatch:GetInsightRuleReport"]
    effect    = "Allow"
    resources = ["arn:aws:cloudwatch:*:*:insight-rule/DynamoDBContributorInsights*"]
  }

  statement {
    actions   = ["iam:PassRole"]
    effect    = "Allow"
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "iam:PassedToService"
      values = [
        "application-autoscaling.amazonaws.com",
        "application-autoscaling.amazonaws.com.cn",
        "dax.amazonaws.com"
      ]
    }
  }

  statement {
    effect    = "Allow"
    actions   = ["iam:CreateServiceLinkedRole"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "iam:AWSServiceName"
      values = [
        "replication.dynamodb.amazonaws.com",
        "dax.amazonaws.com",
        "dynamodb.application-autoscaling.amazonaws.com",
        "contributorinsights.dynamodb.amazonaws.com",
        "kinesisreplication.dynamodb.amazonaws.com"
      ]
    }
  }

  statement {
    sid    = "VisualEditor"
    effect = "Deny"
    actions = [
      "dynamodb:BatchWriteItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteTable"
    ]
    resources = [
      local.dynamodb_adv_mapper_arn,
      local.dynamodb_session_arn
    ]
  }
  statement {

    sid    = "prodReaktaSessions"
    effect = "Deny"
    actions = [
      "dynamodb:BatchGet*",
      "dynamodb:Get*",
      "dynamodb:Query",
      "dynamodb:Scan"
    ]
    resources = [
      local.dynamodb_session_arn

    ]
  }
  statement {

    sid       = "AllowSESAccess"
    effect    = "Allow"
    actions   = ["ses:*"]
    resources = ["*"]
  }

}

resource "aws_iam_policy" "eks_worker_policy" {
  name   = "eks_worker_${var.env_name}_policy"
  policy = data.aws_iam_policy_document.eks_worker_policy.json
}


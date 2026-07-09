resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 1 : 0

  url = local.github_oidc_url

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [
    var.oidc_thumbprint_sha,
  ]
}

resource "aws_iam_role" "github_actions" {
  name = local.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRoleWithWebIdentity"
        Principal = {
          Federated = local.provider_arn
        }
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = local.trusted_subject
          }
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "github_actions" {
  name = "${var.name_prefix}-github-actions-deploy"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EcrLogin"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
        ]
        Resource = "*"
      },
      {
        Sid    = "EcrPushStatusPage"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
        ]
        Resource = var.ecr_repository_arn
      },
      {
        Sid    = "SendDeployCommand"
        Effect = "Allow"
        Action = [
          "ssm:SendCommand",
        ]
        Resource = [
          "arn:aws:ssm:${var.aws_region}::document/AWS-RunShellScript",
          "arn:aws:ssm:${var.aws_region}:${var.aws_account_id}:document/AWS-RunShellScript",
          var.ec2_instance_arn,
        ]
      },
      {
        Sid    = "ReadDeployCommandAndFindInstance"
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ssm:GetCommandInvocation",
        ]
        Resource = "*"
      },
    ]
  })
}

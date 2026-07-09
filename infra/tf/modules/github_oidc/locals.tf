locals {
  github_oidc_url      = "https://token.actions.githubusercontent.com"
  provider_path        = trimprefix(local.github_oidc_url, "https://")
  default_provider_arn = "arn:aws:iam::${var.aws_account_id}:oidc-provider/${local.provider_path}"
  trusted_subject      = "repo:${var.github_owner}/${var.github_repository}:ref:refs/heads/${var.github_branch}"
  role_name            = "${var.name_prefix}-github-actions-role"
  provider_arn         = var.create_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : coalesce(var.existing_oidc_provider_arn, local.default_provider_arn)
}

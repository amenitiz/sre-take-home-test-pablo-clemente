mock_provider "aws" {}

run "github_oidc_contract" {
  command = apply

  module {
    source = "./modules/github_oidc"
  }

  variables {
    name_prefix         = "status-page-challenge"
    aws_region          = "eu-west-3"
    aws_account_id      = "123456789012"
    github_owner        = "amenitiz"
    github_repository   = "sre-take-home-test-pablo-clemente"
    github_branch       = "challenge"
    ecr_repository_arn  = "arn:aws:ecr:eu-west-3:123456789012:repository/status-page"
    ec2_instance_arn    = "arn:aws:ec2:eu-west-3:123456789012:instance/i-1234567890abcdef0"
    oidc_thumbprint_sha = "6938fd4d98bab03faadb97b34396831e3780aea1"
  }

  assert {
    condition     = output.role_name == "status-page-challenge-github-actions-role"
    error_message = "GitHub Actions role name must be predictable for workflow configuration."
  }

  assert {
    condition     = output.trusted_subject == "repo:amenitiz/sre-take-home-test-pablo-clemente:ref:refs/heads/challenge"
    error_message = "GitHub OIDC trust must be restricted to the challenge branch in this repository."
  }

  assert {
    condition     = output.provider_arn == "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
    error_message = "GitHub OIDC must default to the account-global provider ARN to avoid recreating an existing provider."
  }

  assert {
    condition     = output.ecr_repository_arn == "arn:aws:ecr:eu-west-3:123456789012:repository/status-page"
    error_message = "GitHub Actions ECR push policy must target the status-page repository."
  }

  assert {
    condition     = output.ec2_instance_arn == "arn:aws:ec2:eu-west-3:123456789012:instance/i-1234567890abcdef0"
    error_message = "GitHub Actions deploy policy must target the status-page EC2 instance."
  }
}

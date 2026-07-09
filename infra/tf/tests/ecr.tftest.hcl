mock_provider "aws" {}

run "ecr_contract" {
  command = apply

  module {
    source = "./modules/ecr"
  }

  variables {
    repository_name            = "status-page"
    untagged_image_expire_days = 7
    tagged_image_count_limit   = 10
  }

  assert {
    condition     = output.repository_name == "status-page"
    error_message = "ECR repository must be named status-page without an environment suffix."
  }

  assert {
    condition     = output.repository_url != ""
    error_message = "ECR repository URL must be exposed for image push and pull workflows."
  }

  assert {
    condition     = output.repository_arn != ""
    error_message = "ECR repository ARN must be exposed for IAM policies."
  }
}

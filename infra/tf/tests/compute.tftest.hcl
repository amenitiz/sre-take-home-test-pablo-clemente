mock_provider "aws" {}

run "compute_contract" {
  command = apply

  module {
    source = "./modules/compute"
  }

  variables {
    name_prefix             = "status-page-challenge"
    aws_region              = "eu-west-3"
    subnet_id               = "subnet-1234567890abcdef0"
    app_security_group_id   = "sg-1234567890abcdef0"
    target_group_arn        = "arn:aws:elasticloadbalancing:eu-west-3:123456789012:targetgroup/status-page/1234567890abcdef"
    ecr_repository_name     = "status-page"
    app_port                = 3000
    instance_type           = "t3.micro"
    root_volume_size        = 8
    create_instance_profile = false
    instance_profile_name   = null
  }

  assert {
    condition     = output.instance_type == "t3.micro"
    error_message = "The smoke-test EC2 instance must use the low-cost t3.micro type."
  }

  assert {
    condition     = output.app_port == 3000
    error_message = "The EC2 smoke service must listen on the Rails app port 3000."
  }

  assert {
    condition     = output.ubuntu_ami_owner == "099720109477"
    error_message = "The compute module must use Canonical's Ubuntu AMI owner."
  }

  assert {
    condition     = output.ssh_key_configured == false
    error_message = "The EC2 instance must not configure SSH key access."
  }

  assert {
    condition     = output.instance_profile_name == null
    error_message = "The EC2 instance must support launching without an instance profile."
  }

  assert {
    condition     = output.created_instance_profile == false
    error_message = "The compute module must not create an instance profile when disabled."
  }

  assert {
    condition     = output.runs_instance_profile_bootstrap == false
    error_message = "The fallback smoke-test path must skip SSM/ECR bootstrap when no instance profile is attached."
  }
}

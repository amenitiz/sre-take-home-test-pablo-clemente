mock_provider "aws" {}

run "compute_contract" {
  command = apply

  module {
    source = "./modules/compute"
  }

  variables {
    name_prefix                   = "status-page-challenge"
    aws_region                    = "eu-west-3"
    subnet_id                     = "subnet-1234567890abcdef0"
    app_security_group_id         = "sg-1234567890abcdef0"
    target_group_arn              = "arn:aws:elasticloadbalancing:eu-west-3:123456789012:targetgroup/status-page/1234567890abcdef"
    ecr_repository_name           = "status-page"
    app_port                      = 3000
    instance_type                 = "t3.micro"
    root_volume_size              = 8
    create_instance_profile       = false
    instance_profile_name         = null
    app_secret_arn                = null
    enable_cloudwatch_agent       = false
    cloudwatch_log_group_name     = "/status-page/challenge/app"
    cloudwatch_log_retention_days = 7
  }

  assert {
    condition     = output.instance_type == "t3.micro"
    error_message = "The EC2 app instance must use the low-cost t3.micro type."
  }

  assert {
    condition     = output.app_port == 3000
    error_message = "The EC2 app service must listen on the Rails app port 3000."
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
    error_message = "The no-profile path must skip SSM/ECR bootstrap when no instance profile is attached."
  }

  assert {
    condition     = output.runs_package_bootstrap == true
    error_message = "The EC2 bootstrap must install Docker and AWS CLI even when no instance profile is attached."
  }

  assert {
    condition     = output.uses_official_docker_repository == true
    error_message = "The EC2 bootstrap must install Docker Engine from Docker's official apt repository instead of relying on Ubuntu's docker.io package."
  }

  assert {
    condition     = output.uses_official_aws_cli_installer == true
    error_message = "The EC2 bootstrap must install AWS CLI v2 from the official AWS installer instead of relying on Ubuntu's apt package."
  }

  assert {
    condition     = output.writes_app_deploy_script == true
    error_message = "The EC2 bootstrap must write the status page deploy script."
  }

  assert {
    condition     = output.writes_app_systemd_service == true
    error_message = "The EC2 bootstrap must write the status page systemd service."
  }

  assert {
    condition     = output.writes_temporary_smoke_service == false
    error_message = "The EC2 bootstrap must not write the temporary smoke service once the real app deploy path works."
  }

  assert {
    condition     = output.cloudwatch_agent_enabled == false
    error_message = "CloudWatch Agent log shipping must be disabled by default for IAM-restricted sandboxes."
  }

  assert {
    condition     = output.cloudwatch_log_group_name == null
    error_message = "The compute module must not create a CloudWatch log group when CloudWatch Agent is disabled."
  }
}

run "compute_profile_contract" {
  command = apply

  module {
    source = "./modules/compute"
  }

  variables {
    name_prefix                   = "status-page-challenge"
    aws_region                    = "eu-west-3"
    subnet_id                     = "subnet-1234567890abcdef0"
    app_security_group_id         = "sg-1234567890abcdef0"
    target_group_arn              = "arn:aws:elasticloadbalancing:eu-west-3:123456789012:targetgroup/status-page/1234567890abcdef"
    ecr_repository_name           = "status-page"
    app_port                      = 3000
    instance_type                 = "t3.micro"
    root_volume_size              = 8
    create_instance_profile       = true
    instance_profile_name         = null
    app_secret_arn                = "arn:aws:secretsmanager:eu-west-3:123456789012:secret:status-page-challenge/app-env-abc123"
    enable_cloudwatch_agent       = false
    cloudwatch_log_group_name     = "/status-page/challenge/app"
    cloudwatch_log_retention_days = 7
  }

  assert {
    condition     = output.created_instance_profile == true
    error_message = "The compute module must create an instance profile when enabled."
  }

  assert {
    condition     = output.runs_instance_profile_bootstrap == true
    error_message = "The EC2 bootstrap must run SSM/ECR setup when an instance profile is attached."
  }

  assert {
    condition     = output.runs_package_bootstrap == true
    error_message = "The EC2 bootstrap must install Docker and AWS CLI when an instance profile is attached."
  }

  assert {
    condition     = output.uses_official_docker_repository == true
    error_message = "The profile bootstrap must use Docker's official apt repository."
  }

  assert {
    condition     = output.uses_official_aws_cli_installer == true
    error_message = "The profile bootstrap must use the official AWS CLI v2 installer."
  }

  assert {
    condition     = output.writes_app_deploy_script == true
    error_message = "The profile bootstrap must write the status page deploy script."
  }

  assert {
    condition     = output.writes_app_systemd_service == true
    error_message = "The profile bootstrap must write the status page systemd service."
  }

  assert {
    condition     = output.app_secret_access_enabled == true
    error_message = "The EC2 role must receive app secret read access when a secret ARN is provided."
  }
}

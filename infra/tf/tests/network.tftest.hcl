run "network_contract" {
  command = plan

  variables {
    project_name       = "status-page"
    environment        = "test"
    vpc_cidr           = "10.42.0.0/16"
    availability_zones = ["eu-west-3a", "eu-west-3b"]
  }

  assert {
    condition     = output.region == "eu-west-3"
    error_message = "AWS resources must be configured for the eu-west-3 challenge region."
  }

  assert {
    condition     = output.public_subnet_count == 2
    error_message = "The ALB tier must have two public subnets in distinct AZs."
  }

  assert {
    condition     = output.database_subnet_count == 2
    error_message = "The RDS subnet group must have two private database subnets."
  }

  assert {
    condition     = output.has_nat_gateway == false
    error_message = "The cost-conscious network design must not create a NAT Gateway."
  }
}

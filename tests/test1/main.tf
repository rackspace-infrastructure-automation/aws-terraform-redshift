terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  version = "~> 3.0"
  region  = "eu-west-1"
}

resource "random_string" "r_string" {
  length  = 6
  upper   = true
  lower   = false
  number  = false
  special = false
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork?ref=v0.12.1"

  name = "RedShift-Test-${random_string.r_string.result}"
}

module "redshift_sg" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-security_group?ref=v0.12.1"

  name   = "my_test_sg"
  vpc_id = module.vpc.vpc_id
}

module "internal_zone" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-route53_internal_zone?ref=v0.12.0"

  environment = "Development"
  name        = "example.com"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_eip" "redshift_eip" {
}

resource "random_string" "username_string" {
  length  = 8
  special = false
  upper   = false
  lower   = true
  number  = false
}

resource "random_string" "password_string" {
  length      = 16
  lower       = true
  min_lower   = 1
  min_numeric = 1
  min_upper   = 1
  number      = true
  special     = false
  upper       = true
}

module "redshift_test" {
  source = "../../module"

  allow_version_upgrade    = true
  cluster_type             = "multi-node"
  create_route53_record    = true
  db_name                  = "myredshift"
  elastic_ip               = aws_eip.redshift_eip.public_ip
  environment              = "Development"
  internal_record_name     = "redshiftendpoint"
  internal_zone_id         = module.internal_zone.internal_hosted_zone_id
  internal_zone_name       = module.internal_zone.internal_hosted_name
  master_password          = random_string.password_string.result
  master_username          = random_string.username_string.result
  name                     = "rs-test-${random_string.r_string.result}"
  number_of_nodes          = 2
  publicly_accessible      = true
  use_elastic_ip           = true
  rackspace_alarms_enabled = true
  redshift_instance_class  = "dc1.large"
  security_groups          = [module.redshift_sg.redshift_security_group_id]
  skip_final_snapshot      = true
  storage_encrypted        = false
  subnets                  = module.vpc.private_subnets

  tags = {
    TestTag1 = "TestTag1"
    TestTag2 = "TestTag2"
  }
}


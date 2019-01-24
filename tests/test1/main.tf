provider "aws" {
  version = "~> 1.2"
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
  source   = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork?ref=master"
  vpc_name = "RedShift-Test-${random_string.r_string.result}"
}

module "redshift_sg" {
  source        = "git@github.com:rackspace-infrastructure-automation/aws-terraform-security_group?ref=master"
  resource_name = "my_test_sg"
  vpc_id        = "${module.vpc.vpc_id}"
}

module "internal_zone" {
  source        = "git@github.com:rackspace-infrastructure-automation/aws-terraform-route53_internal_zone?ref=master"
  zone_name     = "example.com"
  environment   = "Development"
  target_vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_eip" "redshift_eip" {}

resource "random_string" "username_string" {
  length  = 8
  special = false
  upper   = false
  lower   = true
  number  = false
}

resource "random_string" "password_string" {
  length  = 16
  special = false
  upper   = true
  lower   = true
  number  = true
}

module "redshift_test" {
  source                   = "../../module"
  number_of_nodes          = 2
  create_route53_record    = true
  internal_zone_id         = "${module.internal_zone.internal_hosted_zone_id}"
  internal_zone_name       = "${module.internal_zone.internal_hosted_name}"
  use_elastic_ip           = true
  elastic_ip               = "${aws_eip.redshift_eip.public_ip}"
  internal_record_name     = "redshiftendpoint"
  publicly_accessible      = true
  master_username          = "${random_string.username_string.result}"
  master_password          = "${random_string.password_string.result}"
  redshift_instance_class  = "dc1.large"
  environment              = "Development"
  rackspace_alarms_enabled = true
  subnets                  = ["${module.vpc.private_subnets}"]
  security_group_list      = ["${module.redshift_sg.redshift_security_group_id}"]
  db_name                  = "myredshift"
  cluster_type             = "multi-node"
  allow_version_upgrade    = true
  storage_encrypted        = false
  resource_name            = "rs-test-${random_string.r_string.result}"

  additional_tags = {
    TestTag1 = "TestTag1"
    TestTag2 = "TestTag2"
  }

  skip_final_snapshot = true
}

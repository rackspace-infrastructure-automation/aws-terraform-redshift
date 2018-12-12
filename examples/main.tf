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
  source   = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork?ref=v0.0.6"
  vpc_name = "RedShift-Test-${random_string.r_string.result}"
}

module "redshift_sg" {
  source        = "git@github.com:rackspace-infrastructure-automation/aws-terraform-security_group?ref=v0.0.5"
  resource_name = "my_test_sg"
  vpc_id        = "${module.vpc.vpc_id}"
}

data "aws_kms_secrets" "redshift_credentials" {
  secret {
    name    = "master_username"
    payload = "AQICAHiMkgli+XMjFjJsKicOEKZDP27c/SlrA4KZAicl3BhO7wF/qrG7hnsXOVymU46FUKydAAAAaDBmBgkqhkiG9w0BBwagWTBXAgEAMFIGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMO1xnXU7bNymoyypqAgEQgCUTjRpyQhdU59V69IBYg43wR+JOiNaVZnRm9xwby6th9nK5hQlv"
  }

  secret {
    name    = "master_password"
    payload = "AQICAHiMkgli+XMjFjJsKicOEKZDP27c/SlrA4KZAicl3BhO7wGdlBv+iGhbeKUVUuvGSUZZAAAAaTBnBgkqhkiG9w0BBwagWjBYAgEAMFMGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMirg2/j6IML3SNdpoAgEQgCYQMZxvIeUd2EOKoFKngS/ZTONbWrrXqzImvhXEo94ZoRFmZtXQJQ=="
  }
}

module "internal_zone" {
  source        = "git@github.com:rackspace-infrastructure-automation/aws-terraform-route53_internal_zone?ref=v.0.0.1"
  zone_name     = "example.com"
  environment   = "Development"
  target_vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_eip" "redshift_eip" {}

module "redshift_test" {
  source                  = "git@github.com:rackspace-infrastructure-automation/aws-terraform-redshift?ref=v0.0.1"
  number_of_nodes         = 2
  create_route53_record   = true
  internal_zone_id        = "${module.internal_zone.internal_hosted_zone_id}"
  internal_zone_name      = "${module.internal_zone.internal_hosted_name}"
  use_elastic_ip          = true
  elastic_ip              = "${aws_eip.redshift_eip.public_ip}"
  internal_record_name    = "redshiftendpoint"
  publicly_accessible     = true
  master_username         = "${data.aws_kms_secrets.redshift_credentials.plaintext["master_username"]}"
  master_password         = "${data.aws_kms_secrets.redshift_credentials.plaintext["master_password"]}"
  redshift_instance_class = "dc1.large"
  environment             = "Development"
  enable_rackspace_ticket = true
  subnets                 = ["${module.vpc.private_subnets}"]
  security_group_list     = ["${module.redshift_sg.redshift_security_group_id}"]
  db_name                 = "myredshift"
  cluster_type            = "multi-node"
  allow_version_upgrade   = true
  storage_encrypted       = false
  resource_name           = "rs-test-${random_string.r_string.result}"

  additional_tags = {
    TestTag1 = "TestTag1"
    TestTag2 = "TestTag2"
  }

  skip_final_snapshot       = true
  final_snapshot_identifier = "MyTestFinalSnapshot"
}

/*
 * # aws-terraform-redshift
 *
 * This module creates a redshift cluster and associated route53 record.
 *
 * ## Basic Usage
 *
 * ```
 * module "redshift_test" {
 *  source                  = "git@github.com:rackspace-infrastructure-automation/aws-terraform-redshift?ref=v0.1.0"
 *
 *  allow_version_upgrade     = true
 *  cluster_type              = "multi-node"
 *  create_route53_record     = true
 *  db_name                   = "myredshift"
 *  elastic_ip                = "${aws_eip.redshift_eip.public_ip}"
 *  enable_rackspace_ticket   = true
 *  environment               = "Development"
 *  final_snapshot_identifier = "MyTestFinalSnapshot"
 *  name                      = "rs-test-${random_string.r_string.result}"
 *  number_of_nodes           = 2
 *  internal_record_name      = "redshiftendpoint"
 *  internal_zone_id          = "${module.internal_zone.internal_hosted_zone_id}"
 *  internal_zone_name        = "${module.internal_zone.internal_hosted_name}"
 *  master_password           = "${data.aws_kms_secrets.redshift_credentials.plaintext["master_password"]}"
 *  master_username           = "${data.aws_kms_secrets.redshift_credentials.plaintext["master_username"]}"
 *  publicly_accessible       = true
 *  use_elastic_ip            = true
 *  redshift_instance_class   = "dc1.large"
 *  security_groups           = ["${module.redshift_sg.redshift_security_group_id}"]
 *  skip_final_snapshot       = true
 *  storage_encrypted         = false
 *  subnets                   = ["${module.vpc.private_subnets}"]
 *
 *   tags = {
 *      TestTag1 = "TestTag1"
 *      TestTag2 = "TestTag2"
 *   }
 *
 *  }
 * ```
 *
 * Full working references are available at [examples](examples)
 * ## Other TF Modules Used
 * Using [aws-terraform-cloudwatch_alarm](https://github.com/rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm) to create the following CloudWatch Alarms:
 * 	- redshift_cpu_alarm_high
 * 	- redshift_cluster_health_Ticket
 * 	- redshift_free_storage_space_ticket
 *
 * ## Module variables
 *
 * The following module variables changes have occurred:
 *
 * #### Deprecations
 * - `additional_tags` - marked for deprecation as it no longer meets our standards.
 * - `resource_name`  - marked for deprecation as it no longer meets our standards.
* - `security_group_list`  - marked for deprecation as it no longer meets our standards.
 *
 * #### Additions
 * - `tags` - introduced as a replacement for `additional_tags` to better align with our standards.
 * - `name` - introduced as a replacement for `resource_name` to better align with our standards.
 * - `security_groups` - introduced as a replacement for `security_group_list` to better align with our standards.
 */

locals {
  # favor name over alarm name if both are set
  name = "${var.name != "" ? var.name : var.resource_name}"

  tags = {
    Environment     = "${var.environment}"
    ServiceProvider = "Rackspace"
  }

  additional_tags = "${merge(var.additional_tags, var.tags)}"

  security_groups = "${distinct(concat(var.security_groups, var.security_group_list))}"
}

data "aws_region" "current_region" {}
data "aws_caller_identity" "current_account" {}

resource "aws_redshift_subnet_group" "redshift_subnet_group" {
  name       = "${join("-",list(lower(local.name),"subnetgroup"))}"
  subnet_ids = ["${var.subnets}"]

  tags = "${merge(
    local.tags,
    var.additional_tags
  )}"
}

data "aws_iam_policy_document" "redshift_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["redshift.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "redshift_role" {
  assume_role_policy = "${data.aws_iam_policy_document.redshift_assume_policy.json}"
  name               = "${local.name}-Role"
}

resource "aws_iam_role_policy_attachment" "redshift_policy_attach" {
  count = "${var.count_cluster_role_managed_policy_arns}"

  policy_arn = "${element(var.cluster_role_managed_policy_arns, count.index)}"
}

resource "aws_redshift_parameter_group" "redshift_parameter_group" {
  description = "${join("-", list(var.environment, "parametergroup"))}"
  family      = "redshift-${var.cluster_version}"
  name        = "${join("-", list(lower(local.name),"parametergroup"))}"

  parameter {
    name  = "enable_user_activity_logging"
    value = "true"
  }
}

resource "aws_redshift_cluster" "redshift_cluster" {
  allow_version_upgrade               = "${var.allow_version_upgrade}"
  automated_snapshot_retention_period = "${var.backup_retention_period}"
  availability_zone                   = "${var.availability_zone}"
  cluster_identifier                  = "${join("-", list(lower(local.name), "cluster"))}"
  cluster_subnet_group_name           = "${aws_redshift_subnet_group.redshift_subnet_group.name}"
  cluster_type                        = "${var.cluster_type}"
  cluster_version                     = "${var.cluster_version}"
  cluster_parameter_group_name        = "${aws_redshift_parameter_group.redshift_parameter_group.name}"
  database_name                       = "${var.db_name}"
  elastic_ip                          = "${var.use_elastic_ip && var.publicly_accessible ? var.elastic_ip : ""}"
  final_snapshot_identifier           = "${var.final_snapshot_identifier}"
  encrypted                           = "${var.storage_encrypted}"
  iam_roles                           = ["${aws_iam_role.redshift_role.arn}"]
  kms_key_id                          = "${var.key_id}"
  master_username                     = "${var.master_username}"
  master_password                     = "${var.master_password}"
  node_type                           = "${var.redshift_instance_class}"
  number_of_nodes                     = "${var.number_of_nodes}"
  publicly_accessible                 = "${var.publicly_accessible}"
  skip_final_snapshot                 = "${var.skip_final_snapshot}"
  snapshot_identifier                 = "${var.redshift_snapshot_identifier}"
  port                                = "${var.port}"
  preferred_maintenance_window        = "${var.preferred_maintenance_window}"
  vpc_security_group_ids              = ["${local.security_groups}"]

  tags = "${merge(
    local.tags,
    var.additional_tags
  )}"
}

resource "aws_route53_record" "redshift_internal_record_set" {
  count = "${var.create_route53_record ? 1 : 0}"

  name    = "${var.internal_record_name}.${var.internal_zone_name}"
  records = ["${aws_redshift_cluster.redshift_cluster.endpoint}"]
  ttl     = 300
  type    = "CNAME"
  zone_id = "${var.internal_zone_id}"
}

module "redshift_cpu_alarm_high" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.0.1"

  alarm_description        = "Alarm if ${aws_redshift_cluster.redshift_cluster.id} CPU > ${var.cw_cpu_threshold}% for 5 minutes"
  alarm_name               = "${local.name}-CPUAlarmHigh"
  comparison_operator      = "GreaterThanThreshold"
  evaluation_periods       = 5
  metric_name              = "CPUUtilization"
  namespace                = "AWS/Redshift"
  notification_topic       = "${var.notification_topic}"
  period                   = 60
  rackspace_alarms_enabled = "${var.rackspace_alarms_enabled}"
  rackspace_managed        = "${var.rackspace_managed}"
  severity                 = "urgent"
  statistic                = "Average"
  threshold                = "${var.cw_cpu_threshold}"

  dimensions = [{
    ClusterIdentifier = "${aws_redshift_cluster.redshift_cluster.id}"
  }]
}

module "redshift_cluster_health_Ticket" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.0.1"

  alarm_description        = "Cluster has entered unhealthy state, creating ticket"
  alarm_name               = "${local.name}-CluterHealthTicket"
  comparison_operator      = "LessThanThreshold"
  evaluation_periods       = 5
  metric_name              = "HealthStatus"
  namespace                = "AWS/Redshift"
  notification_topic       = "${var.notification_topic}"
  period                   = 60
  rackspace_alarms_enabled = "${var.rackspace_alarms_enabled}"
  rackspace_managed        = "${var.rackspace_managed}"
  severity                 = "emergency"
  statistic                = "Average"
  threshold                = 1

  dimensions = [{
    ClusterIdentifier = "${aws_redshift_cluster.redshift_cluster.id}"
  }]
}

module "redshift_free_storage_space_ticket" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.0.1"

  alarm_description        = "Consumed storage space has risen above threshold, sending email notification"
  alarm_name               = "${local.name}-FreeStorageSpaceTicket"
  comparison_operator      = "GreaterThanOrEqualToThreshold"
  evaluation_periods       = 30
  metric_name              = "PercentageDiskSpaceUsed"
  namespace                = "AWS/Redshift"
  notification_topic       = "${var.notification_topic}"
  period                   = 60
  rackspace_alarms_enabled = "${var.rackspace_alarms_enabled}"
  rackspace_managed        = "${var.rackspace_managed}"
  severity                 = "urgent"
  statistic                = "Average"
  threshold                = "${var.cw_percentage_disk_used}"
  unit                     = "Percent"

  dimensions = [{
    ClusterIdentifier = "${aws_redshift_cluster.redshift_cluster.id}"
  }]
}

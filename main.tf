locals {
  tags = {
    ServiceProvider = "Rackspace"
    Environment     = "${var.environment}"
  }

  alarm_emergency = "${var.enable_rackspace_ticket ? "arn:aws:sns:${data.aws_region.current_region.name}:${data.aws_caller_identity.current_account.account_id}:rackspace-support-emergency" : ""}"
  alarm_urgent    = "${var.enable_rackspace_ticket ? "arn:aws:sns:${data.aws_region.current_region.name}:${data.aws_caller_identity.current_account.account_id}:rackspace-support-urgent" : ""}"
}

data "aws_region" "current_region" {}
data "aws_caller_identity" "current_account" {}

resource "aws_redshift_subnet_group" "redshift_subnet_group" {
  name       = "${lower("${var.resource_name}-subnetgroup")}"
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
  name               = "${var.resource_name}-Role"
  assume_role_policy = "${data.aws_iam_policy_document.redshift_assume_policy.json}"
}

resource "aws_iam_role_policy_attachment" "redshift_policy_attach" {
  count      = "${var.count_cluster_role_managed_policy_arns}"
  policy_arn = "${element(var.cluster_role_managed_policy_arns, count.index)}"
}

resource "aws_redshift_parameter_group" "redshift_parameter_group" {
  name        = "${lower("${var.resource_name}-parametergroup")}"
  description = "${join("-", list(var.environment, "parametergroup"))}"
  family      = "redshift-${var.cluster_version}"

  parameter {
    name  = "enable_user_activity_logging"
    value = "true"
  }
}

resource "aws_redshift_cluster" "redshift_cluster" {
  cluster_identifier                  = "${lower("${var.resource_name}-cluster")}"
  cluster_type                        = "${var.cluster_type}"
  cluster_version                     = "${var.cluster_version}"
  availability_zone                   = "${var.availability_zone}"
  publicly_accessible                 = "${var.publicly_accessible}"
  elastic_ip                          = "${var.use_elastic_ip && var.publicly_accessible ? var.elastic_ip : ""}"
  master_username                     = "${var.master_username}"
  master_password                     = "${var.master_password}"
  encrypted                           = "${var.storage_encrypted}"
  snapshot_identifier                 = "${var.redshift_snapshot_identifier}"
  vpc_security_group_ids              = ["${var.security_group_list}"]
  iam_roles                           = ["${aws_iam_role.redshift_role.arn}"]
  allow_version_upgrade               = "${var.allow_version_upgrade}"
  kms_key_id                          = "${var.key_id}"
  automated_snapshot_retention_period = "${var.backup_retention_period}"
  preferred_maintenance_window        = "${var.preferred_maintenance_window}"
  node_type                           = "${var.redshift_instance_class}"
  cluster_parameter_group_name        = "${aws_redshift_parameter_group.redshift_parameter_group.name}"
  port                                = "${var.port}"
  database_name                       = "${var.db_name}"
  number_of_nodes                     = "${var.number_of_nodes}"
  cluster_subnet_group_name           = "${aws_redshift_subnet_group.redshift_subnet_group.name}"
  final_snapshot_identifier           = "${var.final_snapshot_identifier}"
  skip_final_snapshot                 = "${var.skip_final_snapshot}"

  tags = "${merge(
    local.tags,
    var.additional_tags
)}"
}

resource "aws_route53_record" "redshift_internal_record_set" {
  count   = "${var.create_route53_record ? 1 : 0}"
  name    = "${var.internal_record_name}.${var.internal_zone_name}"
  type    = "CNAME"
  zone_id = "${var.internal_zone_id}"
  records = ["${aws_redshift_cluster.redshift_cluster.endpoint}"]
  ttl     = 300
}

resource "aws_cloudwatch_metric_alarm" "redshift_cpu_alarm_high" {
  alarm_name          = "${var.resource_name}-CPUAlarmHigh"
  alarm_description   = "Alarm if ${aws_redshift_cluster.redshift_cluster.id} CPU > ${var.cw_cpu_threshold}% for 5 minutes"
  period              = 60
  comparison_operator = "GreaterThanThreshold"
  statistic           = "Average"
  threshold           = "${var.cw_cpu_threshold}"
  evaluation_periods  = 5
  namespace           = "AWS/Redshift"
  metric_name         = "CPUUtilization"
  alarm_actions       = ["${compact(list(local.alarm_emergency))}"]
  ok_actions          = ["${compact(list(local.alarm_emergency))}"]

  dimensions {
    ClusterIdentifier = "${aws_redshift_cluster.redshift_cluster.id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "redshift_cluster_health_Ticket" {
  alarm_name          = "${var.resource_name}-CluterHealthTicket"
  alarm_description   = "Cluster has entered unhealthy state, creating ticket"
  period              = 60
  comparison_operator = "LessThanThreshold"
  statistic           = "Average"
  threshold           = 1
  evaluation_periods  = 5
  namespace           = "AWS/Redshift"
  metric_name         = "HealthStatus"
  alarm_actions       = ["${compact(list(local.alarm_emergency))}"]
  ok_actions          = ["${compact(list(local.alarm_emergency))}"]

  dimensions {
    ClusterIdentifier = "${aws_redshift_cluster.redshift_cluster.id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "redshift_free_storage_space_ticket" {
  alarm_name          = "${var.resource_name}-FreeStorageSpaceTicket"
  alarm_description   = "Consumed storage space has risen above threshold, sending email notification"
  period              = 60
  comparison_operator = "GreaterThanOrEqualToThreshold"
  statistic           = "Average"
  threshold           = "${var.cw_percentage_disk_used}"
  evaluation_periods  = 30
  namespace           = "AWS/Redshift"
  metric_name         = "PercentageDiskSpaceUsed"
  unit                = "Percent"
  alarm_actions       = ["${compact(list(local.alarm_urgent))}"]
  ok_actions          = ["${compact(list(local.alarm_urgent))}"]

  dimensions {
    ClusterIdentifier = "${aws_redshift_cluster.redshift_cluster.id}"
  }
}

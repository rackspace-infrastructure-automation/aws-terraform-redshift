# aws-terraform-patch_baseline

This module creates a redshift cluster and associated route53 record.

## Basic Usage

```
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
```

Full working references are available at [examples](examples)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| additional_tags | Additional tags to be added to the RedShift module resources | map | `<map>` | no |
| allow_version_upgrade | Indicates that engine upgrades will be applied automatically to the Redshift cluster during the maintenance window | string | `true` | no |
| availability_zone | Availability zone in which to initially provision Redshift. | string | `` | no |
| backup_retention_period | The number of days for which automated backups are retained. Setting this parameter to a positive number enables backups. Setting this parameter to 0 disables automated backups | string | `1` | no |
| cluster_role_managed_policy_arns | A comma delimited list of IAM policy ARNs for the ClusterRole IAM role.  IAM ARNs can be found within the Policies section of the AWS IAM console. | list | `<list>` | no |
| cluster_type | Create a single-node or multi-node Redshift cluster | string | `single-node` | no |
| cluster_version | Redshift Engine Version | string | `1.0` | no |
| count_cluster_role_managed_policy_arns | Count of provided policy ARNs provided as a list into variable cluster_role_managed_policy_arns. Must be provided if policies are being given in variable cluster_role_managed_policy_arns. | string | `0` | no |
| create_route53_record | Specifies whether or not to create a route53 CNAME record for the redshift endpoint. internal_zone_id, internal_zone_name, and internal_record_name must be provided if set to true. true or false. | string | `false` | no |
| cw_cpu_threshold | CloudWatch CPUUtilization Threshold | string | `90` | no |
| cw_percentage_disk_used | CloudWatch Percentage of storage consumed threshold | string | `90` | no |
| db_name | Name of initial Redshift database | string | `myredshift` | no |
| elastic_ip | The Elastic IP (EIP) address for the cluster (must have publicly accessible enabled) | string | `` | no |
| enable_rackspace_ticket | Specifies whether alarms will generate Rackspace tickets | string | `false` | no |
| environment | Application environment for which this network is being created. e.g. Development/Production. | string | `Development` | no |
| final_snapshot_identifier | If provided, a final snapshot will be created immediately before deleting the cluster. | string | `myfinalredshiftsnapshot` | no |
| internal_record_name | Record Name for the new Resource Record in the Internal Hosted Zone | string | `` | no |
| internal_zone_id | The Route53 Internal Hosted Zone ID | string | `` | no |
| internal_zone_name | TLD for Internal Hosted Zone | string | `` | no |
| key_id | The ID of the AWS Key Management Service (AWS KMS) key that you want to use to encrypt data in the cluster | string | `` | no |
| master_password | The master password for the Redshift Instance | string | - | yes |
| master_username | The name of master user for the Redshift instance | string | - | yes |
| number_of_nodes | If ClusterType is single-node, this parameter is ignored. If ClusterType is multi-node, NumberOfNodes must be >= 2. | string | `1` | no |
| port | The port number on which the database accepts connections | string | `5439` | no |
| preferred_maintenance_window | The daily time range during which automated backups are created if automated backups are enabled | string | `Sun:05:00-Sun:07:00` | no |
| publicly_accessible | Indicates whether the Redshift cluster is an Internet-facing cluster | string | `false` | no |
| redshift_instance_class | The compute and memory capacity of the nodes within the Redshift cluster | string | `dc1.large` | no |
| redshift_snapshot_identifier | The name of the snapshot from which to create a new cluster | string | `` | no |
| resource_name | The name to be used for resources provisioned by this module | string | - | yes |
| security_group_list | A list of EC2 security groups to assign to this resource. | list | `<list>` | no |
| skip_final_snapshot | Skip final snapshot before deleting the cluster. true or false. | string | `false` | no |
| storage_encrypted | Specifies whether the Redshift cluster is encrypted | string | `false` | no |
| subnets | Subnets for use with this Redshift cluster | list | `<list>` | no |
| use_elastic_ip | Instruct module to use provided Elastic IP Address | string | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| db_port | Cluster endpoint port number |
| jdbc_connection_string | JDBC connection string for cluster |
| redshift_address | Address of database endpoint |
| redshift_cluster_identifier | Redshift cluster identifier |

# aws-terraform-redshift

This module creates a redshift cluster and associated route53 record.

## Basic Usage

```
module "redshift_test" {
source                  = "git@github.com:rackspace-infrastructure-automation/aws-terraform-redshift?ref=v0.0.2"
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
## Other TF Modules Used
Using [aws-terraform-cloudwatch_alarm](https://github.com/rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm) to create the following CloudWatch Alarms:
	- redshift_cpu_alarm_high
	- redshift_cluster_health_Ticket
	- redshift_free_storage_space_ticket

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| additional\_tags | Additional tags to be added to the RedShift module resources | map | `<map>` | no |
| allow\_version\_upgrade | Indicates that engine upgrades will be applied automatically to the Redshift cluster during the maintenance window | string | `"true"` | no |
| availability\_zone | Availability zone in which to initially provision Redshift. | string | `""` | no |
| backup\_retention\_period | The number of days for which automated backups are retained. Setting this parameter to a positive number enables backups. Setting this parameter to 0 disables automated backups | string | `"1"` | no |
| cluster\_role\_managed\_policy\_arns | A comma delimited list of IAM policy ARNs for the ClusterRole IAM role.  IAM ARNs can be found within the Policies section of the AWS IAM console. | list | `<list>` | no |
| cluster\_type | Create a single-node or multi-node Redshift cluster | string | `"single-node"` | no |
| cluster\_version | Redshift Engine Version | string | `"1.0"` | no |
| count\_cluster\_role\_managed\_policy\_arns | Count of provided policy ARNs provided as a list into variable cluster_role_managed_policy_arns. Must be provided if policies are being given in variable cluster_role_managed_policy_arns. | string | `"0"` | no |
| create\_route53\_record | Specifies whether or not to create a route53 CNAME record for the redshift endpoint. internal_zone_id, internal_zone_name, and internal_record_name must be provided if set to true. true or false. | string | `"false"` | no |
| cw\_cpu\_threshold | CloudWatch CPUUtilization Threshold | string | `"90"` | no |
| cw\_percentage\_disk\_used | CloudWatch Percentage of storage consumed threshold | string | `"90"` | no |
| db\_name | Name of initial Redshift database | string | `"myredshift"` | no |
| elastic\_ip | The Elastic IP (EIP) address for the cluster (must have publicly accessible enabled) | string | `""` | no |
| environment | Application environment for which this network is being created. e.g. Development/Production. | string | `"Development"` | no |
| final\_snapshot\_identifier | If provided, a final snapshot will be created immediately before deleting the cluster. | string | `"myfinalredshiftsnapshot"` | no |
| internal\_record\_name | Record Name for the new Resource Record in the Internal Hosted Zone | string | `""` | no |
| internal\_zone\_id | The Route53 Internal Hosted Zone ID | string | `""` | no |
| internal\_zone\_name | TLD for Internal Hosted Zone | string | `""` | no |
| key\_id | The ID of the AWS Key Management Service (AWS KMS) key that you want to use to encrypt data in the cluster | string | `""` | no |
| master\_password | The master password for the Redshift Instance | string | n/a | yes |
| master\_username | The name of master user for the Redshift instance | string | n/a | yes |
| notification\_topic | List of SNS Topic ARNs to use for customer notifications. | list | `<list>` | no |
| number\_of\_nodes | If ClusterType is single-node, this parameter is ignored. If ClusterType is multi-node, NumberOfNodes must be >= 2. | string | `"1"` | no |
| port | The port number on which the database accepts connections | string | `"5439"` | no |
| preferred\_maintenance\_window | The daily time range during which automated backups are created if automated backups are enabled | string | `"Sun:05:00-Sun:07:00"` | no |
| publicly\_accessible | Indicates whether the Redshift cluster is an Internet-facing cluster | string | `"false"` | no |
| rackspace\_alarms\_enabled | Specifies whether alarms will create a Rackspace ticket.  Ignored if rackspace_managed is set to false. | string | `"false"` | no |
| rackspace\_managed | Boolean parameter controlling if instance will be fully managed by Rackspace support teams, created CloudWatch alarms that generate tickets, and utilize Rackspace managed SSM documents. | string | `"true"` | no |
| redshift\_instance\_class | The compute and memory capacity of the nodes within the Redshift cluster | string | `"dc1.large"` | no |
| redshift\_snapshot\_identifier | The name of the snapshot from which to create a new cluster | string | `""` | no |
| resource\_name | The name to be used for resources provisioned by this module | string | n/a | yes |
| security\_group\_list | A list of EC2 security groups to assign to this resource. | list | `<list>` | no |
| skip\_final\_snapshot | Skip final snapshot before deleting the cluster. true or false. | string | `"false"` | no |
| storage\_encrypted | Specifies whether the Redshift cluster is encrypted | string | `"false"` | no |
| subnets | Subnets for use with this Redshift cluster | list | `<list>` | no |
| use\_elastic\_ip | Instruct module to use provided Elastic IP Address | string | `"false"` | no |

## Outputs

| Name | Description |
|------|-------------|
| db\_port | Cluster endpoint port number |
| jdbc\_connection\_string | JDBC connection string for cluster |
| redshift\_address | Address of database endpoint |
| redshift\_cluster\_identifier | Redshift cluster identifier |


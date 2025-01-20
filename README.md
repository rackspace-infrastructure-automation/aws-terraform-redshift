> [!CAUTION]
> This project is end of life. This repo will be deleted on June 2nd 2025.

# aws-terraform-redshift

This module creates a redshift cluster and associated route53 record.

## Basic Usage

```
module "redshift_test" {
 source                  = "git@github.com:rackspace-infrastructure-automation/aws-terraform-redshift?ref=v0.12.0"

 allow_version_upgrade     = true
 cluster_type              = "multi-node"
 create_route53_record     = true
 db_name                   = "myredshift"
 elastic_ip                = aws_eip.redshift_eip.public_ip
 enable_rackspace_ticket   = true
 environment               = "Development"
 final_snapshot_identifier = "MyTestFinalSnapshot"
 name                      = "rs-test-${random_string.r_string.result}"
 number_of_nodes           = 2
 internal_record_name      = "redshiftendpoint"
 internal_zone_id          = module.internal_zone.internal_hosted_zone_id
 internal_zone_name        = module.internal_zone.internal_hosted_name
 master_password           = data.aws_kms_secrets.redshift_credentials.plaintext["master_password"]
 master_username           = data.aws_kms_secrets.redshift_credentials.plaintext["master_username"]
 publicly_accessible       = true
 use_elastic_ip            = true
 redshift_instance_class   = "dc1.large"
 security_groups           = [module.redshift_sg.redshift_security_group_id]
 skip_final_snapshot       = true
 storage_encrypted         = false
 subnets                   = module.vpc.private_subnets

  tags = {
     TestTag1 = "TestTag1"
     TestTag2 = "TestTag2"
  }

 }
```

Full working references are available at [examples](examples)
## Other TF Modules Used  
Using [aws-terraform-cloudwatch\_alarm](https://github.com/rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm) to create the following CloudWatch Alarms:
	- redshift\_cpu\_alarm\_high
	- redshift\_cluster\_health\_Ticket
	- redshift\_free\_storage\_space\_ticket

## Module variables

The following module variables changes have occurred:

#### Deprecations
- `additional_tags` - marked for deprecation as it no longer meets our standards.
- `resource_name`  - marked for deprecation as it no longer meets our standards.
- `security_group_list`  - marked for deprecation as it no longer meets our standards.

#### Additions
- `tags` - introduced as a replacement for `additional_tags` to better align with our standards.
- `name` - introduced as a replacement for `resource_name` to better align with our standards.
- `security_groups` - introduced as a replacement for `security_group_list` to better align with our standards.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |
| aws | >= 2.7.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.7.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| redshift_cluster_health_ticket | git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6 |  |
| redshift_cpu_alarm_high | git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6 |  |
| redshift_free_storage_space_ticket | git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6 |  |

## Resources

| Name |
|------|
| [aws_caller_identity](https://registry.terraform.io/providers/hashicorp/aws/2.7.0/docs/data-sources/caller_identity) |
| [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/2.7.0/docs/data-sources/iam_policy_document) |
| [aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/2.7.0/docs/resources/iam_role) |
| [aws_iam_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/2.7.0/docs/resources/iam_role_policy_attachment) |
| [aws_redshift_cluster](https://registry.terraform.io/providers/hashicorp/aws/2.7.0/docs/resources/redshift_cluster) |
| [aws_redshift_parameter_group](https://registry.terraform.io/providers/hashicorp/aws/2.7.0/docs/resources/redshift_parameter_group) |
| [aws_redshift_subnet_group](https://registry.terraform.io/providers/hashicorp/aws/2.7.0/docs/resources/redshift_subnet_group) |
| [aws_region](https://registry.terraform.io/providers/hashicorp/aws/2.7.0/docs/data-sources/region) |
| [aws_route53_record](https://registry.terraform.io/providers/hashicorp/aws/2.7.0/docs/resources/route53_record) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_tags | Additional tags to be added to the RedShift module resources. [**Deprecated** in favor of `tags`]. It will be removed in future releases. `tags` is merged with `additional_tags` until `additional_tags` is removed. | `map(string)` | `{}` | no |
| allow\_version\_upgrade | Indicates that engine upgrades will be applied automatically to the Redshift cluster during the maintenance window | `bool` | `true` | no |
| availability\_zone | Availability zone in which to initially provision Redshift. | `string` | `""` | no |
| backup\_retention\_period | The number of days for which automated backups are retained. Setting this parameter to a positive number enables backups. Setting this parameter to 0 disables automated backups | `number` | `1` | no |
| cluster\_role\_managed\_policy\_arns | A comma delimited list of IAM policy ARNs for the ClusterRole IAM role.  IAM ARNs can be found within the Policies section of the AWS IAM console. | `list(string)` | `[]` | no |
| cluster\_type | Create a single-node or multi-node Redshift cluster | `string` | `"single-node"` | no |
| cluster\_version | Redshift Engine Version | `string` | `"1.0"` | no |
| count\_cluster\_role\_managed\_policy\_arns | Count of provided policy ARNs provided as a list into variable cluster\_role\_managed\_policy\_arns. Must be provided if policies are being given in variable cluster\_role\_managed\_policy\_arns. | `number` | `0` | no |
| create\_route53\_record | Specifies whether or not to create a route53 CNAME record for the redshift endpoint. internal\_zone\_id, internal\_zone\_name, and internal\_record\_name must be provided if set to true. true or false. | `bool` | `false` | no |
| cw\_cpu\_threshold | CloudWatch CPUUtilization Threshold | `number` | `90` | no |
| cw\_percentage\_disk\_used | CloudWatch Percentage of storage consumed threshold | `number` | `90` | no |
| db\_name | Name of initial Redshift database | `string` | `"myredshift"` | no |
| elastic\_ip | The Elastic IP (EIP) address for the cluster (must have publicly accessible enabled) | `string` | `""` | no |
| environment | Application environment for which this network is being created. e.g. Development/Production. | `string` | `"Development"` | no |
| final\_snapshot\_identifier | If provided, a final snapshot will be created immediately before deleting the cluster. | `string` | `"myfinalredshiftsnapshot"` | no |
| internal\_record\_name | Record Name for the new Resource Record in the Internal Hosted Zone | `string` | `""` | no |
| internal\_zone\_id | The Route53 Internal Hosted Zone ID | `string` | `""` | no |
| internal\_zone\_name | TLD for Internal Hosted Zone | `string` | `""` | no |
| key\_id | The ID of the AWS Key Management Service (AWS KMS) key that you want to use to encrypt data in the cluster | `string` | `""` | no |
| master\_password | The master password for the Redshift Instance | `string` | n/a | yes |
| master\_username | The name of master user for the Redshift instance | `string` | n/a | yes |
| name | The name to be used for resources provisioned by this module. Either `name` or `resource_name` **must** contain a non-default value. | `string` | `""` | no |
| notification\_topic | List of SNS Topic ARNs to use for customer notifications. | `list(string)` | `[]` | no |
| number\_of\_nodes | If ClusterType is single-node, this parameter is ignored. If ClusterType is multi-node, NumberOfNodes must be >= 2. | `number` | `1` | no |
| port | The port number on which the database accepts connections | `number` | `5439` | no |
| preferred\_maintenance\_window | The daily time range during which automated backups are created if automated backups are enabled | `string` | `"Sun:05:00-Sun:07:00"` | no |
| publicly\_accessible | Indicates whether the Redshift cluster is an Internet-facing cluster | `bool` | `false` | no |
| rackspace\_alarms\_enabled | Specifies whether alarms will create a Rackspace ticket.  Ignored if rackspace\_managed is set to false. | `bool` | `false` | no |
| rackspace\_managed | Boolean parameter controlling if instance will be fully managed by Rackspace support teams, created CloudWatch alarms that generate tickets, and utilize Rackspace managed SSM documents. | `bool` | `true` | no |
| redshift\_instance\_class | The compute and memory capacity of the nodes within the Redshift cluster | `string` | `"dc1.large"` | no |
| redshift\_snapshot\_identifier | The name of the snapshot from which to create a new cluster | `string` | `""` | no |
| resource\_name | The name to be used for resources provisioned by this module. [**Deprecated** in favor of `name`]. It will be removed in future releases. `name` supercedes `resource_name` when both are set. Either `name` or `resource_name` **must** contain a non-default value.. | `string` | `""` | no |
| security\_group\_list | A list of EC2 security groups to assign to this resource. [**Deprecated** in favor of `security_groups`]. It will be removed in future releases. `security_groups` is merged with `security_group_list` until `security_group_list` is removed. | `list(string)` | `[]` | no |
| security\_groups | A list of EC2 security groups to assign to this resource. `security_groups` is merged with `security_group_list` until `security_group_list` is removed in a future release. | `list(string)` | `[]` | no |
| skip\_final\_snapshot | Skip final snapshot before deleting the cluster. true or false. | `bool` | `false` | no |
| storage\_encrypted | Specifies whether the Redshift cluster is encrypted | `bool` | `false` | no |
| subnets | Subnets for use with this Redshift cluster | `list(string)` | `[]` | no |
| tags | Additional tags to be added to the RedShift module resources. `tags` is merged with `additional_tags` until `additional_tags` is removed in a future release. | `map(string)` | `{}` | no |
| use\_elastic\_ip | Instruct module to use provided Elastic IP Address | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| db\_port | Cluster endpoint port number |
| jdbc\_connection\_string | JDBC connection string for cluster |
| redshift\_address | Address of database endpoint |
| redshift\_cluster\_identifier | Redshift cluster identifier |

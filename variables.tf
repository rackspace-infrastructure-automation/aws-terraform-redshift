variable "additional_tags" {
  description = "Additional tags to be added to the RedShift module resources. [**Deprecated** in favor of `tags`]. It will be removed in future releases. `tags` is merged with `additional_tags` until `additional_tags` is removed."
  default     = {}
  type        = map(string)

}

variable "allow_version_upgrade" {
  description = "Indicates that engine upgrades will be applied automatically to the Redshift cluster during the maintenance window"
  default     = true
  type        = bool
}

variable "availability_zone" {
  description = "Availability zone in which to initially provision Redshift."
  default     = ""
  type        = string
}

variable "backup_retention_period" {
  description = "The number of days for which automated backups are retained. Setting this parameter to a positive number enables backups. Setting this parameter to 0 disables automated backups"
  default     = 1
  type        = number
}

variable "cluster_role_managed_policy_arns" {
  description = "A comma delimited list of IAM policy ARNs for the ClusterRole IAM role.  IAM ARNs can be found within the Policies section of the AWS IAM console."
  default     = []
  type        = list(string)
}

variable "cluster_type" {
  description = "Create a single-node or multi-node Redshift cluster"
  default     = "single-node"
  type        = string
}

variable "cluster_version" {
  description = "Redshift Engine Version"
  default     = "1.0"
  type        = string
}

variable "count_cluster_role_managed_policy_arns" {
  description = "Count of provided policy ARNs provided as a list into variable cluster_role_managed_policy_arns. Must be provided if policies are being given in variable cluster_role_managed_policy_arns."
  default     = 0
  type        = number
}

variable "create_route53_record" {
  description = "Specifies whether or not to create a route53 CNAME record for the redshift endpoint. internal_zone_id, internal_zone_name, and internal_record_name must be provided if set to true. true or false."
  default     = false
  type        = bool
}

variable "cw_cpu_threshold" {
  description = "CloudWatch CPUUtilization Threshold"
  default     = 90
  type        = number
}

variable "cw_percentage_disk_used" {
  description = "CloudWatch Percentage of storage consumed threshold"
  default     = 90
  type        = number
}

variable "db_name" {
  description = "Name of initial Redshift database"
  default     = "myredshift"
  type        = string
}

variable "elastic_ip" {
  description = "The Elastic IP (EIP) address for the cluster (must have publicly accessible enabled)"
  default     = ""
  type        = string
}

variable "environment" {
  description = "Application environment for which this network is being created. e.g. Development/Production."
  default     = "Development"
  type        = string
}

variable "final_snapshot_identifier" {
  description = "If provided, a final snapshot will be created immediately before deleting the cluster."
  default     = "myfinalredshiftsnapshot"
  type        = string
}

variable "internal_record_name" {
  description = "Record Name for the new Resource Record in the Internal Hosted Zone"
  default     = ""
  type        = string
}

variable "internal_zone_id" {
  description = "The Route53 Internal Hosted Zone ID"
  default     = ""
  type        = string
}

variable "internal_zone_name" {
  description = "TLD for Internal Hosted Zone"
  default     = ""
  type        = string
}

variable "key_id" {
  description = "The ID of the AWS Key Management Service (AWS KMS) key that you want to use to encrypt data in the cluster"
  default     = ""
  type        = string
}

variable "master_password" {
  description = "The master password for the Redshift Instance"
  type        = string
}

variable "master_username" {
  description = "The name of master user for the Redshift instance"
  type        = string
}

variable "name" {
  description = "The name to be used for resources provisioned by this module. Either `name` or `resource_name` **must** contain a non-default value."
  default     = ""
  type        = string
}

variable "notification_topic" {
  description = "List of SNS Topic ARNs to use for customer notifications."
  default     = []
  type        = list(string)
}

variable "number_of_nodes" {
  description = "If ClusterType is single-node, this parameter is ignored. If ClusterType is multi-node, NumberOfNodes must be >= 2."
  default     = 1
  type        = number
}

variable "port" {
  description = "The port number on which the database accepts connections"
  default     = 5439
  type        = number
}

variable "preferred_maintenance_window" {
  description = "The daily time range during which automated backups are created if automated backups are enabled"
  default     = "Sun:05:00-Sun:07:00"
  type        = string
}

variable "publicly_accessible" {
  description = "Indicates whether the Redshift cluster is an Internet-facing cluster"
  default     = false
  type        = bool
}

variable "redshift_instance_class" {
  description = "The compute and memory capacity of the nodes within the Redshift cluster"
  default     = "dc1.large"
  type        = string
}

variable "redshift_snapshot_identifier" {
  description = "The name of the snapshot from which to create a new cluster"
  default     = ""
  type        = string
}

variable "resource_name" {
  description = "The name to be used for resources provisioned by this module. [**Deprecated** in favor of `name`]. It will be removed in future releases. `name` supercedes `resource_name` when both are set. Either `name` or `resource_name` **must** contain a non-default value.."
  default     = ""
  type        = string
}

variable "security_group_list" {
  description = "A list of EC2 security groups to assign to this resource. [**Deprecated** in favor of `security_groups`]. It will be removed in future releases. `security_groups` is merged with `security_group_list` until `security_group_list` is removed."
  default     = []
  type        = list(string)
}

variable "security_groups" {
  description = "A list of EC2 security groups to assign to this resource. `security_groups` is merged with `security_group_list` until `security_group_list` is removed in a future release."
  default     = []
  type        = list(string)
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot before deleting the cluster. true or false."
  default     = false
  type        = bool
}

variable "storage_encrypted" {
  description = "Specifies whether the Redshift cluster is encrypted"
  default     = false
  type        = bool
}

variable "subnets" {
  description = "Subnets for use with this Redshift cluster"
  default     = []
  type        = list(string)
}

variable "use_elastic_ip" {
  description = "Instruct module to use provided Elastic IP Address"
  default     = false
  type        = bool
}

variable "rackspace_alarms_enabled" {
  description = "Specifies whether alarms will create a Rackspace ticket.  Ignored if rackspace_managed is set to false."
  default     = false
  type        = bool
}

variable "rackspace_managed" {
  description = "Boolean parameter controlling if instance will be fully managed by Rackspace support teams, created CloudWatch alarms that generate tickets, and utilize Rackspace managed SSM documents."
  default     = true
  type        = bool
}

variable "tags" {
  description = "Additional tags to be added to the RedShift module resources. `tags` is merged with `additional_tags` until `additional_tags` is removed in a future release."
  default     = {}
  type        = map(string)
}


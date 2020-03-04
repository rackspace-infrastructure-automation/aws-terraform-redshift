output "db_port" {
  description = "Cluster endpoint port number"
  value       = aws_redshift_cluster.redshift_cluster.port
}

output "jdbc_connection_string" {
  description = "JDBC connection string for cluster"
  value       = "jdbc:redshift://${aws_redshift_cluster.redshift_cluster.endpoint}:${aws_redshift_cluster.redshift_cluster.port}/${aws_redshift_cluster.redshift_cluster.database_name}"
}

output "redshift_address" {
  description = "Address of database endpoint"
  value       = aws_redshift_cluster.redshift_cluster.endpoint
}

output "redshift_cluster_identifier" {
  description = "Redshift cluster identifier"
  value       = aws_redshift_cluster.redshift_cluster.id
}


output "database_host" {
  value = "${aws_instance.database.private_dns}"
}
output "elb_name" {
  value = "${aws_elb.webserver.dns_name}"
}

output "webserver_security_group" {
  value = "${aws_security_group.webserver.id}"
}

output "efs_mount_target_dns" {
  description = "Address of the mount target provisioned."
  value       = "${aws_efs_file_system.nfs.dns_name}"
}
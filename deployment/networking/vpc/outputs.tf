output "id" {
  value = "${aws_vpc.main.id}"
}

output "cidr_block" {
  value = "${aws_vpc.main.cidr_block}"
}

output "external_subnets" {
  value = ["${aws_subnet.external.*.id}"]
}

output "internal_subnets" {
  value = ["${aws_subnet.internal.*.id}"]
}

output "nat_instances" {
  value = ["${aws_instance.nat_instance.*.id}"]
}

output "security_group" {
  value = "${aws_vpc.main.default_security_group_id}"
}

output "availability_zones" {
  value = ["${aws_subnet.external.*.availability_zone}"]
}

output "internal_rtb_id" {
  value = "${join(",", aws_route_table.internal.*.id)}"
}

output "external_rtb_id" {
  value = "${aws_route_table.external.id}"
}

output "ssh_key_name" {
  value = "${aws_key_pair.public_ssh_key.key_name}"
}
output "region" {
  value = "${var.region}"
}

output "availability_zones" {
  value = "${module.vpc.availability_zones}"
}

output "internal_subnets" {
  value = "${module.vpc.internal_subnets}"
}

output "external_subnets" {
  value = "${module.vpc.external_subnets}"
}

output "environment" {
  value = "${var.environment}"
}

output "vpc_id" {
  value = "${module.vpc.id}"
}

output "elb_name" {
  value = "${module.webserver.elb_name}"
}

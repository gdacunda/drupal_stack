provider "aws" {
  region     = "${var.region}"
}

terraform {
  backend "s3" { }
}

module "vpc" {
  source             = "networking/vpc"
  cidr               = "${var.cidr}"
  internal_subnets   = "${var.internal_subnets}"
  external_subnets   = "${var.external_subnets}"
  availability_zones = "${var.availability_zones}"
  environment        = "${var.environment}",
  ssh_pubkey_file    = "${var.ssh_pubkey_file}",
  nat_instance_type  = "${var.nat_instance_type}"
}

module "bastion" {
  source          = "networking/bastion"
  region          = "${var.region}"
  instance_type   = "${var.bastion_instance_type}"
  vpc_id          = "${module.vpc.id}"
  subnet_ids      = "${module.vpc.external_subnets}"
  ssh_key_name    = "${module.vpc.ssh_key_name}"
  environment     = "${var.environment}",
}

module "webserver" {
  source          = "webserver"
  region          = "${var.region}"
  vpc_id          = "${module.vpc.id}"
  ssh_key_name    = "${module.vpc.ssh_key_name}"
  environment     = "${var.environment}",
  webserver_instance_type   = "${var.webserver_instance_type}",
  webserver_security_groups = ["${module.bastion.internal_ssh_security_group}"],
  availability_zones = "${var.availability_zones}"
  internal_subnet_ids = "${module.vpc.internal_subnets}",
  external_subnet_ids = "${module.vpc.external_subnets}",
  webserver_image_tag = "${var.webserver_image_tag}"
}

module "database" {
  source          = "database"
  region          = "${var.region}"
  vpc_id          = "${module.vpc.id}"
  ssh_key_name    = "${module.vpc.ssh_key_name}"
  environment     = "${var.environment}",
  database_instance_type   = "${var.database_instance_type}",
  database_security_groups = ["${module.bastion.internal_ssh_security_group}"],
  webserver_security_group = "${module.webserver.webserver_security_group}",
  availability_zone  = "${var.availability_zones[0]}"
  subnet_id         = "${module.vpc.internal_subnets[0]}",
  database_image_tag = "${var.database_image_tag}"
}

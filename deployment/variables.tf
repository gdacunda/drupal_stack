variable "environment" {
  description = "the name of your environment, e.g. \"prod-west\""
}

variable "region" {
  description = "the AWS region in which resources are created, you must set the availability_zones variable as well if you define this value to something other than the default"
}

variable "cidr" {
  description = "the CIDR block to provision for the VPC, if set to something other than the default, both internal_subnets and external_subnets have to be defined as well"
}

variable "internal_subnets" {
  description = "a list of CIDRs for internal subnets in your VPC, must be set if the cidr variable is defined, needs to have as many elements as there are availability zones"
  type        = "list"
}

variable "external_subnets" {
  description = "a list of CIDRs for external subnets in your VPC, must be set if the cidr variable is defined, needs to have as many elements as there are availability zones"
  type        = "list"
}

variable "availability_zones" {
  description = "a comma-separated list of availability zones, defaults to all AZ of the region, if set to something other than the defaults, both internal_subnets and external_subnets have to be defined as well"
  type        = "list"
}

variable "bastion_instance_type" {
  description = "Instance type for the bastion"
}

variable "nat_instance_type" {
  description = "Instance type for the nat gateway"
}

variable "webserver_instance_type" {
  description = "Instance type for the webserver"
}

variable "database_instance_type" {
  description = "Instance type for the database"
}

variable "ssh_pubkey_file" {
  description = "Path to an SSH public key"
}

variable "webserver_image_tag" {
}

variable "webserver_cert_arn" {
}

variable "datadog_api_key" {
}

variable "webserver_min_size" {
}

variable "webserver_max_size" {
}

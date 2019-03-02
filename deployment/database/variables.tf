variable "vpc_id" {
  description = "The VPC ID"
}

variable "region" {
  description = "The AWS region to create resources in."
}

variable "ssh_key_name" {
  type = "string"
}

variable "subnet_id" {
}

variable "environment" {
  description = "Environment tag, e.g prod"
}

variable "availability_zone" {
}

variable "database_instance_type" {
  description = "EC2 instance type to use for the DB instances."
}

variable "database_security_groups" {
  type        = "list"
}

variable "webserver_security_group" {
}

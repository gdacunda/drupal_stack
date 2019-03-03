variable "vpc_id" {
  description = "The VPC ID"
}

variable "region" {
  description = "The AWS region to create resources in."
}

variable "webserver_instance_type" {
  description = "EC2 instance type to use for the Webserver instances."
}

variable "webserver_security_groups" {
  type = "list"
}

variable "ssh_key_name" {
  type = "string"
}

variable "internal_subnet_ids" {
  type = "list"
}

variable "external_subnet_ids" {
  type = "list"
}

variable "environment" {
  description = "Environment tag, e.g prod"
}

variable "max_size" {
  type = "string"
  description = "Max number of bastion instances running simultaneously"
  default = "1"
}

variable "min_size" {
  type = "string"
  description = "Min number of bastion instances running simultaneously"
  default = "1"
}

variable "desired_capacity" {
  type = "string"
  description = "The desired number of bastion instances that should be running at any time"
  default = "1"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = "list"
}

variable "webserver_image_tag" {
}

variable "webserver_cert_arn" {
}


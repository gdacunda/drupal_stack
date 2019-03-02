variable "vpc_id" {
  description = "The VPC ID"
}

variable "region" {
  type = "string"
  description = "AWS region in which the Bastion should be deployed"
}

variable "environment" {
  type = "string"
  description = "dev, test, production, etc"
}

variable "instance_type" {
  type = "string"
  description = "Instance type of the Bastion host"
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

variable "ssh_key_name" {
  type = "string"
}

variable "subnet_ids" {
  type = "list"
}

environment = "challenge"
region      = "us-east-1"
cidr        = "10.30.0.0/16"

internal_subnets   = ["10.30.0.0/19", "10.30.64.0/19"]
external_subnets   = ["10.30.32.0/20", "10.30.96.0/20"]
availability_zones = ["us-east-1a", "us-east-1b"]
ssh_pubkey_file    = "networking/keys/admin_ssh_key.pub"

bastion_instance_type    = "t2.micro"
nat_instance_type        = "t2.micro"
webserver_instance_type  = "t2.micro"
database_instance_type   = "t2.micro"

webserver_image_tag = "1.0.52"
webserver_min_size = 2
webserver_max_size = 2

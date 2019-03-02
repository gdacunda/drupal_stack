data "aws_ami" "amazon_linux_ami" {
  most_recent      = true
  name_regex = "amzn-ami-hvm-*"
  owners     = ["amazon"]
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "image-type"
    values = ["machine"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "hypervisor"
    values = ["xen"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_security_group" "database_servers" {
  name = "${var.environment}-database-servers"
  description = "Allow inbound traffic from WebServers"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    security_groups = ["${var.webserver_security_group}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_instance" "database" {
  availability_zone = "${var.availability_zone}"
  key_name          = "${var.ssh_key_name}"
  ami               = "${data.aws_ami.amazon_linux_ami.id}"
  instance_type     = "${var.database_instance_type}"
  source_dest_check = false
  subnet_id         = "${var.subnet_id}"
  vpc_security_group_ids = ["${aws_security_group.database_servers.id}","${var.database_security_groups}"]
  user_data              = "${file(format("%s/user_data.sh", path.module))}"

  lifecycle {
    # Ignore changes to the AMI data source.
    ignore_changes = ["ami"]
  }

  tags {
    Name        = "${var.environment}-database"
    Environment = "${var.environment}"
  }
}

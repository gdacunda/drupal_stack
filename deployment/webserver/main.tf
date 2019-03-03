data "aws_ami" "amazon_linux_ami" {
  most_recent = true
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

/**
* NFS
*/
resource "aws_efs_file_system" "nfs" {
  encrypted                       = "false"
  performance_mode                = "generalPurpose"
  provisioned_throughput_in_mibps = "0"
  throughput_mode                 = "bursting"

  tags {
    "Name" = "${var.environment}-nfs"
    "Environment" = "${var.environment}"
  }
}

resource "aws_efs_mount_target" "default" {
  count           = "${length(var.internal_subnet_ids)}"
  file_system_id  = "${aws_efs_file_system.nfs.id}"
  subnet_id       = "${element(var.internal_subnet_ids, count.index)}"
  security_groups = ["${aws_security_group.nfs.id}"]
}

resource "aws_security_group" "nfs" {
  name        = "${var.environment}-nfs"
  description = "Allow NFS traffic."
  vpc_id      = "${var.vpc_id}"

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    from_port       = "2049"                     # NFS
    to_port         = "2049"
    protocol        = "tcp"
    security_groups = ["${aws_security_group.webserver.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    "Name" = "${var.environment}-nfs"
    "Environment" = "${var.environment}"
  }

}


/**
 * Load Balancers
 */

resource "aws_security_group" "load_balancers" {
  name = "load-balancers"
  description = "Allow HTTPS inbound traffic"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = 8888
    to_port = 8888
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_elb" "webserver" {
  name = "${var.environment}-webserver"
  security_groups = ["${aws_security_group.load_balancers.id}"]
  subnets         = ["${var.external_subnet_ids}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  listener {
    lb_protocol = "https"
    lb_port = 8888
    instance_protocol = "http"
    instance_port = 8888
    ssl_certificate_id = "${var.webserver_cert_arn}"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 5
    timeout = 5
    target = "HTTP:8888/core/install.php"
    interval = 10
  }
}

resource "aws_lb_cookie_stickiness_policy" "default" {
  name                     = "lbpolicy"
  load_balancer            = "${aws_elb.webserver.id}"
  lb_port                  = 8888
  cookie_expiration_period = 600
}

resource "aws_security_group" "webserver" {
  name = "webserver"
  description = "Allow inbound traffic from Load Balancers"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = 8888
    to_port = 8888
    protocol = "tcp"
    security_groups = ["${aws_security_group.load_balancers.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "template_file" "user_data" {
  template = "${file(format("%s/user_data.sh", path.module))}"
  vars = {
    webserver_image_tag = "${var.webserver_image_tag}"
    efs_system_id = "${aws_efs_file_system.nfs.id}"
  }
}

resource "aws_launch_configuration" "webserver" {
  name_prefix                 = "${var.environment}-webserver-"
  image_id                    = "${data.aws_ami.amazon_linux_ami.id}"
  instance_type               = "${var.webserver_instance_type}"
  associate_public_ip_address = false
  key_name                    = "${var.ssh_key_name}"
  security_groups             = ["${var.webserver_security_groups}", "${aws_security_group.webserver.id}"]
  enable_monitoring           = true
  user_data                   = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "webserver" {
  name_prefix          = "asg-${aws_launch_configuration.webserver.name}"
  min_size             = "${var.min_size}"
  max_size             = "${var.max_size}"
  desired_capacity     = "${var.desired_capacity}"
  health_check_type    = "ELB"
  launch_configuration = "${aws_launch_configuration.webserver.name}"
  vpc_zone_identifier  = ["${var.internal_subnet_ids}"]
  load_balancers       = ["${aws_elb.webserver.id}"]
  min_elb_capacity     = "${var.min_size}"
  termination_policies = ["OldestLaunchConfiguration"]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${var.environment}-webserver"
    propagate_at_launch = true
  }
  tag {
    key                 = "Environment"
    value               = "${var.environment}"
    propagate_at_launch = true
  }
}

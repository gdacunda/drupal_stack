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

resource "aws_launch_configuration" "bastion_launch_config" {
    name_prefix                 = "${var.environment}-bastion-"
    image_id                    = "${data.aws_ami.amazon_linux_ami.id}"
    instance_type               = "${var.instance_type}"
    associate_public_ip_address = true
    key_name                    = "${var.ssh_key_name}"
    security_groups             = ["${aws_security_group.external_ssh.id}"]
    enable_monitoring           = true
    user_data                   = "${file(format("%s/user_data.sh", path.module))}"

    lifecycle {
        create_before_destroy = true
    }
}


resource "aws_autoscaling_group" "bastion_asg" {
    name_prefix               = "${var.environment}-bastion-"
    max_size                  = "${var.max_size}"
    min_size                  = "${var.min_size}"
    desired_capacity          = "${var.desired_capacity}"
    launch_configuration      = "${aws_launch_configuration.bastion_launch_config.name}"
    health_check_type         = "EC2"
    vpc_zone_identifier       = ["${var.subnet_ids}"]

    lifecycle {
        create_before_destroy = true
    }

    tag {
        key                 = "Name"
        value               = "${var.environment}-bastion"
        propagate_at_launch = true
    }
    tag {
        key                 = "Environment"
        value               = "${var.environment}"
        propagate_at_launch = true
    }
}

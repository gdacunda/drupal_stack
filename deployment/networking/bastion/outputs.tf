output "ami_id" {
    value = "${data.aws_ami.amazon_linux_ami.id}"
    description = "AMI ID of the Bastion"
}

output "launch_configuration_id" {
    value = "${aws_launch_configuration.bastion_launch_config.id}"
    description = "Launch configuration ID of the Bastion"
}

output "auto_scaling_group_id" {
    value = "${aws_autoscaling_group.bastion_asg.id}"
    description = "Auto scaling group id of the Bastion"
}

output "internal_ssh_security_group" {
    value = "${aws_security_group.internal_ssh.id}"
}

// External SSH allows ssh connections on port 22 from the world.
output "external_ssh" {
    value = "${aws_security_group.external_ssh.id}"
}

// Internal SSH allows ssh connections from the external ssh security group.
output "internal_ssh" {
    value = "${aws_security_group.internal_ssh.id}"
}

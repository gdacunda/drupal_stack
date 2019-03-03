provider "aws" {
  region     = "${var.region}"
}

resource "aws_s3_bucket" "terraform-state-storage" {
  bucket = "${var.bucket}"
  acl = "private"

  # This is good for just in case the file gets corrupted or something bad.
  versioning {
    enabled = true
  }

  tags {
    Name = "${var.region}-terraform-states"
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_server_certificate" "webserver_cert" {
  name_prefix      = "${var.webserver_cert_name}-cert-"
  certificate_body = "${file(var.webserver_ca_cert_file)}"
  private_key      = "${file(var.webserver_cert_key_file)}"

  lifecycle {
    create_before_destroy = true
  }
}


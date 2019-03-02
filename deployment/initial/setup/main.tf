provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
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

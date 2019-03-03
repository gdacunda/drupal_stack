output "bucket" {
  value = "${aws_s3_bucket.terraform-state-storage.bucket}"
}

output "iam_certificate_arn" {
  value = "${aws_iam_server_certificate.webserver_cert.arn}"
}
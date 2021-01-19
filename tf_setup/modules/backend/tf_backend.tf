resource "aws_s3_bucket" "tf_remote_backend_s3_bucket" {
  bucket = "tf-remote-backend-bucket-${var.ENV}"
  acl    = "private"

  versioning {
    enabled = true
  }  
}

output "s3_bucket_id" {
    value = aws_s3_bucket.tf_remote_backend_s3_bucket.id
}

output "s3_bucket_arn" {
    value = aws_s3_bucket.tf_remote_backend_s3_bucket.arn
}

output "s3_bucket_region" {
    value = aws_s3_bucket.tf_remote_backend_s3_bucket.region
}
output "website_url" {
  value = "http://${aws_s3_bucket_website_configuration.blog.website_endpoint}"
}

output "website_bucket" {
  value = aws_s3_bucket.blog.id
}
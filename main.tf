resource "aws_s3_bucket" "blog" {
  bucket        = "my-blog-public-demo"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "blog" {
  bucket = aws_s3_bucket.blog.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Public ACL
resource "aws_s3_bucket_acl" "blog" {
  depends_on = [aws_s3_bucket_ownership_controls.blog]
  bucket     = aws_s3_bucket.blog.id
  acl        = "public-read"
}

#Public access block deshabilitado
resource "aws_s3_bucket_public_access_block" "blog" {
  bucket                  = aws_s3_bucket.blog.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "blog" {
  bucket = aws_s3_bucket.blog.id
  index_document { suffix = "index.html" }
  error_document { key    = "error.html" }
}

resource "aws_s3_bucket_policy" "blog" {
  bucket     = aws_s3_bucket.blog.id
  depends_on = [aws_s3_bucket_public_access_block.blog]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicRead"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.blog.arn}/*"
    }]
  })
}

resource "aws_s3_bucket" "this" {
  bucket = var.name

  acl    = "private"

  tags = {
    Project = var.project
  }
}

resource "aws_s3_bucket_policy" "this_policy" {
  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:root"
        }
        Action   = "s3:*"
        Resource = [
          "arn:aws:s3:::${var.name}",
          "arn:aws:s3:::${var.name}/*"
        ]
      }
    ]
  })
}

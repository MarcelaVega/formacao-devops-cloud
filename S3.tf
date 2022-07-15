resource "aws_s3_bucket" "bucket" {
  bucket        = "media.${var.dns.name}"
  force_destroy = true
  tags = {
    Name = "media.${var.dns.name}"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket-access" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "allow_access_from_cdn" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_cdn.json
}

data "aws_iam_policy_document" "allow_access_from_cdn" {
  statement {
    principals {
      type        = "AWS"
      identifiers = module.cloudfront.cloudfront_origin_access_identity_iam_arns
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.bucket.arn}/*",
    ]
  }
}

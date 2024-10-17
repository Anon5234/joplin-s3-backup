# Create an S3 bucket named "joplin-backup-bucket"
resource "aws_s3_bucket" "joplin_backup" {
  bucket = "joplin-backup-bucket"
}

# Set ownership controls for the S3 bucket to ensure bucket ownership settings are managed properly
resource "aws_s3_bucket_ownership_controls" "joplin_backup_owner" {
  bucket = aws_s3_bucket.joplin_backup.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Enable S3 bucket versioning
resource "aws_s3_bucket_versioning" "joplin_backup_versioning" {
  bucket = aws_s3_bucket.joplin_backup.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Set the ACL for the S3 bucket
resource "aws_s3_bucket_acl" "joplin_backup_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.joplin_backup_owner]

  bucket = aws_s3_bucket.joplin_backup.id
  acl    = "private"
}

# Define server-side encryption for the S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.joplin_backup.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access for the S3 bucket
resource "aws_s3_bucket_public_access_block" "joplin_backup_public_block" {
  bucket = aws_s3_bucket.joplin_backup.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enforce HTTPS-only access
resource "aws_s3_bucket_policy" "https_enforcement" {
  bucket = aws_s3_bucket.joplin_backup.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "EnforceHTTPS",
        "Effect" : "Deny",
        "Principal" : "*",
        "Action" : "s3:*",
        "Resource" : [
          "${aws_s3_bucket.joplin_backup.arn}",
          "${aws_s3_bucket.joplin_backup.arn}/*"
        ],
        "Condition" : {
          "Bool" : {
            "aws:SecureTransport" : "false"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_lifecycle_configuration" "joplin_backup_lifecycle" {
  bucket = aws_s3_bucket.joplin_backup.id

  # Rule 1: Transition current objects to Glacier after 60 days
  rule {
    id     = "rule-1"
    status = "Enabled"

    filter {
      # Apply this rule to all objects matchin ^joplin_backup_*
      prefix = "joplin_backup_"
    }

    # Transition to Glacier storage class after 60 days
    transition {
      days          = 60
      storage_class = "GLACIER"
    }

  }

  # Rule 2: Manage noncurrent (previous) versions of objects
  rule {
    id     = "rule-2"
    status = "Enabled"

    filter {}

    # Transition noncurrent versions to Glacier after 30 days
    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "GLACIER"
    }

    # Expire noncurrent versions after 90 days
    noncurrent_version_expiration {
      noncurrent_days = 120
    }
  }

  # Rule 3: Abort incomplete multipart uploads after 7 days
  rule {
    id     = "rule-3"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

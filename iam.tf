# Create an IAM role that can be assumed for backup purposes
resource "aws_iam_role" "backup_role" {
  name = "joplin-backup-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "${aws_iam_user.backup_user.arn}"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

# Create an IAM user named "backup-user"
resource "aws_iam_user" "backup_user" {
  name = "backup-user"
}

# Create access keys for the IAM user to authenticate programmatically
resource "aws_iam_access_key" "backup_user_key" {
  user = aws_iam_user.backup_user.name
}

# Define an IAM policy that grants the backup role access to the S3 bucket
resource "aws_iam_policy" "s3_backup_policy" {
  name        = "s3-backup-policy"
  description = "Policy to allow access to the S3 backup bucket"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
        ],
        "Resource" : [
          "${aws_s3_bucket.joplin_backup.arn}/*"
        ]
      }
    ]
  })
}

# Attach the S3 backup policy to the IAM role
resource "aws_iam_role_policy_attachment" "backup_policy_attachment" {
  role       = aws_iam_role.backup_role.name
  policy_arn = aws_iam_policy.s3_backup_policy.arn
}
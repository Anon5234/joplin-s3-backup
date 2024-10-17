# S3 Backup Setup

This repository contains Terraform configurations for setting up an Amazon S3 bucket to store backups, specifically designed for Joplin notes. The setup includes IAM roles and policies for secure access, server-side encryption, and permissions management.

## Files in This Repository

1. iam.tf

**IAM Role for Backup**: Defines an IAM role named `joplin-backup-role` that can be assumed for backup operations. It includes a trust policy that allows an IAM user to assume the role.

**IAM User Creation**: Creates an IAM user named `backup-user` for programmatic access to the S3 bucket.

**Access Keys**: Generates access keys for the IAM user for authentication.

**IAM Policy**: Creates an IAM policy (`s3-backup-policy`) that allows the backup role to put objects in the S3 bucket.

**Policy Attachment**: Attaches the `s3-backup-policy` to the backup role.

2. providers.tf

**AWS Provider Setup**: Specifies the AWS provider version (~> 5.0) and configures the provider to use the region referenced in variables.tf.

3. s3.tf

**S3 Bucket Creation**: Creates an S3 bucket named `joplin-backup-bucket` for storing backup files.

**Ownership Controls**: Configures ownership controls to set `BucketOwnerPreferred`, ensuring proper management of object ownership.

**Bucket ACL**: Sets the ACL to `private` to ensure that only the bucket owner has access.

**Server-Side Encryption**: Configures server-side encryption using AES-256 to ensure data at rest is protected.

**Public Access Block**: Blocks all public access to ensure data is only accessible privately.

**HTTPS-Only Enforcement**: Adds a bucket policy that denies requests made over HTTP, ensuring that data is only accessed securely over HTTPS.

**S3 Versioning**: Enables versioning for the S3 bucket, allowing you to retain previous versions of objects in case of accidental deletion or modification.

**Lifecycle Management**: Configures lifecycle rules to:

	- Transition objects to Glacier after 60 days.
	- Transition noncurrent (older) versions of objects to Glacier after 30 days and expire them after 120 days.
	- Abort incomplete multipart uploads after 7 days.

## Prerequisites

**Terraform**: Make sure you have Terraform installed. This configuration was developed with Terraform version 1.0 or later.

**AWS Credentials**: You need AWS credentials configured locally (either through `~/.aws/credentials` or environment variables).

## How to Use

**Clone the Repository**:

```
git clone https://github.com/Anon5234/Joplin_Backup_S3.git
cd s3_backup_setup
```

**Initialize Terraform**:

```
terraform init
```

**Review the Plan**:

Before applying, review the changes Terraform will make to ensure they meet your requirements.

```
terraform plan
```

**Apply the Configuration**:

Deploy the S3 bucket and IAM resources.

```
terraform apply
```

**Access Keys**: The output will contain the Access Key ID and Secret Access Key for the `backup-user`. Ensure these are handled securely.

## Security Considerations

**Access Keys**: The secret access keys generated for the `backup-user` should be stored securely.

**HTTPS Enforcement**: This setup enforces HTTPS for accessing the S3 bucket, which helps in protecting data in transit.

**Versioning and Lifecycle Management**: With versioning enabled, older versions of objects are retained, and lifecycle rules are applied to manage object storage costs effectively (e.g., by transitioning data to Glacier).

## Notes

**Bucket Name**: The bucket name `joplin-backup-bucket` is globally unique. You may need to change it if there's a conflict.

**Environment-Specific Changes**: Adjust the AWS region in providers.tf if you need the resources in a different region.

##  Contributing
Feel free to open issues or submit pull requests to improve this script!

## License
This project is licensed under the MIT License.


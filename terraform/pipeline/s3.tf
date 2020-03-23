#
# bucket to store artifacts
#

resource aws_s3_bucket artifacts_bucket {
  bucket        = var.project_name
  acl           = "private"
  force_destroy = true
}
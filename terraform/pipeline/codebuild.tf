resource aws_codebuild_project codebuild {
  name         = var.project_name
  service_role = aws_iam_role.codebuild_role.arn

  source {
    # type            = "CODECOMMIT"
    # location        = aws_codecommit_repository.repository.clone_url_http
    # git_clone_depth = 1

    type = "CODEPIPELINE"
  }

  artifacts {
    # type           = "S3"
    # location       = aws_s3_bucket.artifacts_bucket.bucket
    # path           = "builds"
    # namespace_type = "BUILD_ID"
    # name           = "build.zip"
    # packaging      = "ZIP"

    type = "CODEPIPELINE"
  }

  environment {
    type            = "LINUX_CONTAINER"
    image           = "aws/codebuild/docker:18.09.0-1.7.0"
    compute_type    = "BUILD_GENERAL1_SMALL"
    privileged_mode = true
  }
}

#
# codebuild assume role policy
#

# trust relationships
data aws_iam_policy_document codebuild_assume_role_policy {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource aws_iam_role codebuild_role {
  name               = "${var.project_name}-codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role_policy.json
}

#
# codebuild policy
#

# inline policy data
data aws_iam_policy_document codebuild_policy {
  statement {
    actions = [
      "codecommit:GitPull",
    ]

    resources = [aws_codecommit_repository.repository.arn]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = ["${aws_s3_bucket.artifacts_bucket.arn}/*"]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }
}

resource aws_iam_role_policy codebuild_policy {
  name   = "${var.project_name}-codebuild-policy"
  policy = data.aws_iam_policy_document.codebuild_policy.json
  role   = aws_iam_role.codebuild_role.name
}
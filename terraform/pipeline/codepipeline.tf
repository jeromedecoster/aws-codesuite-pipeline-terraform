resource aws_codepipeline codepipeline {
  name     = var.project_name
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.artifacts_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source"]

      configuration = {
        RepositoryName       = var.project_name
        BranchName           = "master"
        PollForSourceChanges = "false"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name     = "Build"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"

      configuration = {
        ProjectName = var.project_name
      }

      input_artifacts  = ["source"]
      output_artifacts = ["build"]
    }
  }

  stage {
    name = "Deploy"

    action {
      name     = "Deploy"
      category = "Deploy"
      owner    = "AWS"
      provider = "S3"
      version  = "1"

      configuration = {
        BucketName = aws_s3_bucket.artifacts_bucket.bucket
        ObjectKey  = "public"
        Extract    = "true"
      }

      input_artifacts = ["build"]
    }
  }
}

#
# codebuild assume role policy
#

# trust relationships
data aws_iam_policy_document codepipeline_assume_role_policy {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource aws_iam_role codepipeline_role {
  name               = "${var.project_name}-codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role_policy.json
}

#
# codepipeline policy
#

# inline policy data
data aws_iam_policy_document codepipeline_policy {
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:UploadPart",
    ]

    resources = ["${aws_s3_bucket.artifacts_bucket.arn}/*"]
  }

  statement {
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]

    resources = [aws_codebuild_project.codebuild.arn]
  }

  statement {
    actions = [
      "codecommit:GetBranch",
      "codecommit:GetCommit",
      "codecommit:GetUploadArchiveStatus",
      "codecommit:UploadArchive",
    ]

    resources = [aws_codecommit_repository.repository.arn]
  }
}

resource aws_iam_role_policy codepipeline_policy {
  name   = "${var.project_name}-codepipeline-policy"
  policy = data.aws_iam_policy_document.codepipeline_policy.json
  role   = aws_iam_role.codepipeline_role.name
}


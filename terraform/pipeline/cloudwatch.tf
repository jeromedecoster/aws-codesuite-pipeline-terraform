resource aws_cloudwatch_event_rule codecommit_change_event_rule {
  name          = "${var.project_name}-codecommit-change"
  event_pattern = local.event_pattern_json
}

# create event pattern json for the event rule
locals {
  event_pattern = {
    source      = ["aws.codecommit"]
    detail-type = ["CodeCommit Repository State Change"]
    resources : [aws_codecommit_repository.repository.arn]
  }

  event_pattern_json = jsonencode(local.event_pattern)
}

#
# cloudwatch events assume role policy
#

# trust relationships
data aws_iam_policy_document cloudwatch_events_assume_role_policy {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource aws_iam_role cloudwatch_events_role {
  name               = "${var.project_name}-cloudwatch-events-role"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_events_assume_role_policy.json
}

#
# cloudwatch events policy
#

# inline policy data
data aws_iam_policy_document cloudwatch_events_policy {
  statement {
    actions = ["codepipeline:StartPipelineExecution"]

    resources = [aws_codepipeline.codepipeline.arn]
  }
}

resource aws_iam_role_policy cloudwatch_events_policy {
  name   = "${var.project_name}-cloudwatch-events-policy"
  policy = data.aws_iam_policy_document.cloudwatch_events_policy.json
  role   = aws_iam_role.cloudwatch_events_role.name
}

resource aws_cloudwatch_event_target codecommit_change_event_target {
  # The name of the rule you want to add targets to.
  rule = aws_cloudwatch_event_rule.codecommit_change_event_rule.name
  # The Amazon Resource Name (ARN) associated of the target.
  arn = aws_codepipeline.codepipeline.arn
  # The Amazon Resource Name (ARN) of the IAM role to be used for this target when the rule is triggered.
  role_arn = aws_iam_role.cloudwatch_events_role.arn
}
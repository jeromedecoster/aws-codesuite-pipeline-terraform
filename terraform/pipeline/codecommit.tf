#
# repository to store the source code
#

resource aws_codecommit_repository repository {
  repository_name = var.project_name
  description     = "terraformed repository"
}

output clone_url_http {
  value = aws_codecommit_repository.repository.clone_url_http
}

output clone_url_ssh {
  value = aws_codecommit_repository.repository.clone_url_ssh
}

#
# User with git push + pull access to the repository 
#

resource aws_iam_user user {
  name = "${var.project_name}-commit-user"
}

resource aws_iam_user_ssh_key user {
  username   = aws_iam_user.user.name
  encoding   = "SSH"
  public_key = file("ssh_rsa.pub")
}

resource aws_iam_user_policy user_policy {
  name   = "${var.project_name}-user-policy"
  user   = aws_iam_user.user.name
  policy = data.aws_iam_policy_document.user_policy.json
}

data aws_iam_policy_document user_policy {
  statement {
    actions = [
      "codecommit:GitPull",
      "codecommit:GitPush",
    ]

    resources = [aws_codecommit_repository.repository.arn]
  }
}

output user_id {
  value = aws_iam_user.user.unique_id
}

output ssh_public_key_id {
  value = aws_iam_user_ssh_key.user.ssh_public_key_id
}

data "aws_caller_identity" "current" {}
locals {
  prefix              = "emperia-pdp"
  root_dir            = "../../.."
  app_dir             = "${local.root_dir}/app"
  account_id          = data.aws_caller_identity.current.account_id
  ecr_repository_name = "${local.prefix}-lambda-container-${var.stage}"
  ecr_image_tag       = "latest"
}

resource "aws_iam_role" "lambda" {
  name               = "${local.prefix}-lambda-role-${var.stage}"
  assume_role_policy = <<EOF
{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": "sts:AssumeRole",
                "Principal": {
                    "Service": "lambda.amazonaws.com"
                },
                "Effect": "Allow"
            }
        ]
}
    EOF
}

data "aws_iam_policy_document" "lambda" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect    = "Allow"
    resources = ["*"]
    sid       = "CreateCloudWatchLogs"
  }

  statement {
    actions = [
      "codecommit:GitPull",
      "codecommit:GitPush",
      "codecommit:GitBranch",
      "codecommit:ListBranches",
      "codecommit:CreateCommit",
      "codecommit:GetCommit",
      "codecommit:GetCommitHistory",
      "codecommit:GetDifferences",
      "codecommit:GetReferences",
      "codecommit:BatchGetCommits",
      "codecommit:GetTree",
      "codecommit:GetObjectIdentifier",
      "codecommit:GetMergeCommit"
    ]
    effect    = "Allow"
    resources = ["*"]
    sid       = "CodeCommit"
  }
  statement {
    actions = [
      "ssm:GetParameter"
    ]
    effect    = "Allow"
    resources = ["*"]
    sid       = "ReadParameters"
  }
}

resource "aws_iam_policy" "lambda" {
  name   = "${local.prefix}-lambda-policy-${var.stage}"
  path   = "/"
  policy = data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}

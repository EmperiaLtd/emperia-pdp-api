provider "aws" {
  region  = var.region
  profile = "default"
}

data "aws_caller_identity" "current" {}

locals {
  prefix              = "Emperia-PDP"
  root_dir            = "../.."
  app_dir             = "${local.root_dir}/app"
  account_id          = data.aws_caller_identity.current.account_id
  ecr_repository_name = "${local.prefix}-lambda-container-${local.stage}"
  ecr_image_tag       = "latest"
}

resource "aws_ecr_repository" "repo" {
  name = local.ecr_repository_name
}

# The null_resource resource implements the standard resource lifecycle
# but takes no further action.

# The triggers argument allows specifying an arbitary set of values that,
# when changed, will cause the resource to be replaced.

resource "null_resource" "ecr_image" {
  triggers = {
    dir_md5     = md5(join("", [for f in fileset("${local.app_dir}", "**") : file("${local.app_dir}/${f}")]))
    docker_file = md5(file("${path.module}/${local.root_dir}/Dockerfile.aws.lambda"))
  }

  # The local-exec provisioner invokes a local executable after a resource is created.
  # This invokes a process on the machine running Terraform, not on the resource.
  # path.module: the filesystem path of the module where the expression is placed.

  provisioner "local-exec" {
    command = <<EOF
            aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${local.account_id}.dkr.ecr.${var.region}.amazonaws.com
            cd ${path.module}/${local.root_dir}
            docker build -t ${aws_ecr_repository.repo.repository_url}:${local.ecr_image_tag} . -f Dockerfile.aws.lambda
            docker push ${aws_ecr_repository.repo.repository_url}:${local.ecr_image_tag}
            EOF
  }
}

data "aws_ecr_image" "lambda_image" {
  depends_on = [
    null_resource.ecr_image
  ]
  repository_name = local.ecr_repository_name
  image_tag       = local.ecr_image_tag
}

resource "aws_iam_role" "lambda" {
  name               = "${local.prefix}-lambda-role-${local.stage}"
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

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
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
}

resource "aws_iam_policy" "lambda" {
  name   = "${local.prefix}-lambda-policy-${local.stage}"
  path   = "/"
  policy = data.aws_iam_policy_document.lambda.json
}

resource "aws_lambda_function" "Emperia-PDP-lambda-function" {
  depends_on = [
    null_resource.ecr_image
  ]

  function_name = "${local.prefix}-lambda-${local.stage}"
  role          = aws_iam_role.lambda.arn
  timeout       = 3
  image_uri     = "${aws_ecr_repository.repo.repository_url}@${data.aws_ecr_image.lambda_image.id}"
  package_type  = "Image"

  environment {
    variables = {
      stage_name                = local.stage
      env_aws_access_key        = var.env_aws_access_key
      env_aws_secret_access_key = var.env_aws_secret_access_key
    }
  }
}

resource "aws_cloudwatch_log_group" "Emperia-PDP" {
  name = "/aws/lambda/${aws_lambda_function.Emperia-PDP-lambda-function.function_name}"

  retention_in_days = 30
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.Emperia-PDP-lambda-function.arn
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API
  source_arn = "${aws_apigatewayv2_api.Emperia-PDP-gateway.execution_arn}/*/*"
}

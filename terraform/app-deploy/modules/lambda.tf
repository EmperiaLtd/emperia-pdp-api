data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  prefix              = "emperia-pdp"
  root_dir            = "../../.."
  app_dir             = "${local.root_dir}/app"
  account_id          = data.aws_caller_identity.current.account_id
  ecr_repository_name = "${local.prefix}-lambda-container-${local.stage}"
  ecr_image_tag       = "latest"
}

resource "aws_ecr_repository" "repo" {
  name = local.ecr_repository_name
}

# The null_resource resource implements the standard resource lifecycle.


# The triggers argument allows specifying an arbitary set of values that ,
# when changed, will cause the resource to be replaced.

resource "null_resource" "ecr_image" {
  triggers = {
    dir_md5     = md5(join("", [for f in fileset("${local.app_dir}", "*") : filebase64("${local.app_dir}/${f}")]))
    docker_file = md5(filebase64("${path.module}/${local.root_dir}/Dockerfile.aws.lambda"))
  }

  # The local-exec provisioner invokes a local executable after a resource iss created.
  # This invokes a process on the machine running Terraform, not on the resource.
  # path.module: the filesystem path of the module where the expression is placed

  provisioner "local-exec" {
    command = <<EOF
            aws ecr get-login-password --region ${data.aws_region.current.name} | docker login --username AWS --password-stdin ${local.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com
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

resource "aws_lambda_function" "emperia-pdp-lambda-function" {
  depends_on = [
    null_resource.ecr_image
  ]

  function_name = "${local.prefix}-lambda-${local.stage}"
  role          = var.iam_role_lambda_arn
  timeout       = 30
  image_uri     = "${aws_ecr_repository.repo.repository_url}@${data.aws_ecr_image.lambda_image.id}"
  package_type  = "Image"

  environment {
    variables = {
      stage_name                    = local.stage
      env_aws_access_key            = var.env_aws_access_key
      env_aws_secret_access_key     = var.env_aws_secret_access_key
      db_host_dev                   = var.db_host_dev
      db_password_dev               = var.db_password_dev
      db_port_dev                   = var.db_port_dev
      db_host_prod                  = var.db_host_prod
      db_password_prod              = var.db_password_prod
      db_port_prod                  = var.db_port_prod
    }
  }
}

resource "aws_cloudwatch_log_group" "emperia-pdp" {
  name = "/aws/lambda/${aws_lambda_function.emperia-pdp-lambda-function.function_name}"

  retention_in_days = 30
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.emperia-pdp-lambda-function.arn
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API
  source_arn = "${aws_apigatewayv2_api.emperia-pdp-gateway.execution_arn}/*/*"
}

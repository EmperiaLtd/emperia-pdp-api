module "iam_module" {
  source = "./modules/iam_module"
  providers = {
    aws = aws.eu-west-2
  }
  stage = local.stage
}

module "api_gateway_module_us-east-1" {
  source = "./modules/api_gateway_module"
  providers = {
    aws = aws.us-east-1
   }
   stage = local.stage
   authorization_audience =  local.authorization_audience
   authorization_issuer   =  local.authorization_issuer
}

module "lambda_module_us-east-1" {
  source = "./modules/lambda_module"
  providers = {
    aws = aws.us-east-1
  }
  stage = local.stage
  iam_role_lambda_arn = module.iam_module.iam_role_lambda_arn
}

module "api_gateway_integration_module_us-east-1" {
  source = "./modules/api_gateway_integration_module"
  providers = {
    aws = aws.us-east-1
  }
  aws_lambda_function_arn = module.lambda_module_us-east-1.aws_lambda_function_arn
  aws_lambda_function_invoke_arn = module.lambda_module_us-east-1.aws_lambda_function_invoke_arn
  api_gateway_execution_arn = module.api_gateway_module_us-east-1.api_gateway_execution_arn
  api_gateway_id = module.api_gateway_module_us-east-1.api_gateway_id
}

module "api_gateway_module_eu-west-2" {
  source = "./modules/api_gateway_module"
  providers = {
    aws = aws.eu-west-2
   }
   stage = local.stage
   authorization_audience =  local.authorization_audience
   authorization_issuer   =  local.authorization_issuer
}
module "lambda_module_eu-west-2" {
  source = "./modules/lambda_module"
  providers = {
    aws = aws.eu-west-2
  }
  stage = local.stage
  iam_role_lambda_arn = module.iam_module.iam_role_lambda_arn
}

module "api_gateway_integration_module_eu-west-2" {
  source = "./modules/api_gateway_integration_module"
  providers = {
    aws = aws.eu-west-2
  }
  aws_lambda_function_arn = module.lambda_module_eu-west-2.aws_lambda_function_arn
  aws_lambda_function_invoke_arn = module.lambda_module_eu-west-2.aws_lambda_function_invoke_arn
  api_gateway_execution_arn = module.api_gateway_module_eu-west-2.api_gateway_execution_arn
  api_gateway_id = module.api_gateway_module_eu-west-2.api_gateway_id
}

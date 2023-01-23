module "iam_module" {
  source = "./modules/iam_module"
  providers = {
    aws = aws.eu-west-2
  }
  development_authorization_issuer = var.development_authorization_issuer
  staging_authorization_issuer = var.staging_authorization_issuer
  prod_authorization_issuer = var.prod_authorization_issuer
  development_authorization_audience = var.development_authorization_audience
  staging_authorization_audience = var.staging_authorization_audience
  prod_authorization_audience = var.prod_authorization_audience
}

module "api_gateway_module_us-east-1" {
  source = "./modules/api_gateway_module"
  providers = {
    aws = aws.us-east-1
   }
   stage = "development"
}

module "us-east-1" {
  source = "./modules/lambda_module"
  providers = {
    aws = aws.us-east-1
  }
  env_aws_access_key = var.env_aws_access_key
  env_aws_secret_access_key = var.env_aws_secret_access_key
  app_version = var.app_version
  s3_bucket_name = var.s3_bucket_name
  backend_remote_state_s3_bucket = var.backend_remote_state_s3_bucket
  development_authorization_issuer = var.development_authorization_issuer
  staging_authorization_issuer = var.staging_authorization_issuer
  prod_authorization_issuer = var.prod_authorization_issuer
  development_authorization_audience = var.development_authorization_audience
  staging_authorization_audience = var.staging_authorization_audience
  prod_authorization_audience = var.prod_authorization_audience
  iam_role_lambda_arn = module.iam_module.iam_role_lambda_arn
  api_gateway_execution_arn = module.api_gateway_module_us-east-1.api_gateway_execution_arn
}

module "api_gateway_module_eu-west-2" {
  source = "./modules/api_gateway_module"
  providers = {
    aws = aws.eu-west-2
   }
   stage = "development"
}
module "eu-west-2" {
  source = "./module/lambda_module"
  providers = {
    aws = aws.eu-west-2
  }
  env_aws_access_key = var.env_aws_access_key
  env_aws_secret_access_key = var.env_aws_secret_access_key
  app_version = var.app_version
  s3_bucket_name = var.s3_bucket_name
  backend_remote_state_s3_bucket = var.backend_remote_state_s3_bucket
  development_authorization_issuer = var.development_authorization_issuer
  staging_authorization_issuer = var.staging_authorization_issuer
  prod_authorization_issuer = var.prod_authorization_issuer
  development_authorization_audience = var.development_authorization_audience
  staging_authorization_audience = var.staging_authorization_audience
  prod_authorization_audience = var.prod_authorization_audience
  iam_role_lambda_arn = module.iam_module.iam_role_lambda_arn
  api_gateway_execution_arn = module.api_gateway_module_eu-west-2.api_gateway_execution_arn
}

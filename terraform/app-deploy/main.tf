module "iam_module" {
  source = "./iam_module"
  providers = {
    aws = aws
  }
  development_authorization_issuer = var.development_authorization_issuer
  staging_authorization_issuer = var.staging_authorization_issuer
  prod_authorization_issuer = var.prod_authorization_issuer
  development_authorization_audience = var.development_authorization_audience
  staging_authorization_audience = var.staging_authorization_audience
  prod_authorization_audience = var.prod_authorization_audience
}

module "us-east-1" {
  source = "./modules"
  providers = {
    aws = aws.us-east-1
  }
  env_aws_access_key = var.env_aws_access_key
  env_aws_secret_access_key = var.env_aws_secret_access_key
  AWS_ACCESS_KEY_ID = var.env_aws_access_key
  AWS_SECRET_ACCESS_KEY = var.env_aws_secret_access_key
  AWS_DEFAULT_REGION = "us-east-1"
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
}
module "eu-west-2" {
  source = "./modules"
  providers = {
    aws = aws
  }
  AWS_ACCESS_KEY_ID = var.env_aws_access_key
  AWS_SECRET_ACCESS_KEY = var.env_aws_secret_access_key
  AWS_DEFAULT_REGION = "eu-west-2"
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
}

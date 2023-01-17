module "iam_module" {
  source = "./iam_module"
  providers = {
    aws = aws
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
  db_host_dev = var.db_host_dev
  db_password_dev = var.db_password_dev
  db_port_dev = var.db_port_dev
  db_host_prod = var.db_host_prod
  db_password_prod = var.db_password_prod
  db_port_prod = var.db_port_prod
}

module "us-east-1" {
  source = "./modules"
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
  db_host_dev = var.db_host_dev
  db_password_dev = var.db_password_dev
  db_port_dev = var.db_port_dev
  db_host_prod = var.db_host_prod
  db_password_prod = var.db_password_prod
  db_port_prod = var.db_port_prod
  iam_role_lambda_arn = module.iam_module.iam_role_lambda_arn
}
module "eu-west-2" {
  source = "./modules"
  providers = {
    aws = aws
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
  db_host_dev = var.db_host_dev
  db_password_dev = var.db_password_dev
  db_port_dev = var.db_port_dev
  db_host_prod = var.db_host_prod
  db_password_prod = var.db_password_prod
  db_port_prod = var.db_port_prod
  iam_role_lambda_arn = module.iam_module.iam_role_lambda_arn
}

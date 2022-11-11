# Input variable definitions

variable "region" {
  description = "AWS region for all resources."
  type        = string
  default     = "eu-west-2"
}

variable "env_aws_access_key" {
  default = "xxx"
}

variable "env_aws_secret_access_key" {
  default = "xxx"
}

variable "app_version" {
  default = "1.0.0"
}

variable "s3_bucket_name" {
  default = "terraform-state-emperia-pdp"
}

variable "backend_remote_state_s3_bucket" {
  default = "terraform-state-emperia-pdp"
}

variable "dev_authorization_issuer"{
  default = "https://emperia.eu.auth0.com/"

}
variable "staging_authorization_issuer"{
    default = "https://emperia-staging.eu.auth0.com/"
}
variable "prod_authorization_issuer"{
  default = "https://emperia-production.eu.auth0.com/"
}
 variable "dev_authorization_audience" {
  default = "https://artemis-apollo-jwt-authorizer"
}
 variable "staging_authorization_audience" {
  default = "https://artemis-apollo-jwt-authorizer-staging"
}
 variable "prod_authorization_audience" {
  default = "https://artemis-apollo-jwt-authorizer-production"
}
locals {
  stage       = terraform.workspace == "default" ? "dev" : terraform.workspace
  authorization_issuer =  terraform.workspace == "production" ? var.prod_authorization_issuer : (terraform.workspace == "staging" ? var.staging_authorization_issuer : var.dev_authorization_issuer)
  authorization_audience = terraform.workspace == "production" ? var.prod_authorization_audience : (terraform.workspace == "staging" ? var.staging_authorization_audience: var.dev_authorization_audience)
}
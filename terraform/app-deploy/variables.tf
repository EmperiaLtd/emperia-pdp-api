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

variable "backend_state_locking_dynamoDB" {
  default = "terraform-state-locking-Emperia-PDP"
}

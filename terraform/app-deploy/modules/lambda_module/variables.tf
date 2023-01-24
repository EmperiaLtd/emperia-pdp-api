# Input variable definitions
variable "iam_role_lambda_arn" {
  description = "arn of iam role for lambda"
}

variable "stage" {
    description = "current working stage (development/production)"
    default = "development"
}

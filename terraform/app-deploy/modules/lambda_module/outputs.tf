output "lambda_name" {
  value = aws_lambda_function.emperia-pdp-lambda-function.id
}

output "aws_lambda_function_alias_arn" {
  value = aws_lambda_alias.pdp-lambda_alias.arn
}

output "aws_lambda_function_alias_invoke_arn" {
  value = aws_lambda_alias.pdp-lambda_alias.invoke_arn
}

output "lambda_name" {
  value = aws_lambda_function.emperia-pdp-lambda-function.id
}

output "aws_lambda_function_arn" {
  value = aws_lambda_function.emperia-pdp-lambda-function.arn
}

output "aws_lambda_function_invoke_arn" {
  value = aws_lambda_function.emperia-pdp-lambda-function.invoke_arn
}

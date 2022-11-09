output "lambda_name" {
  value = aws_lambda_function.Emperia-PDP-lambda-function.id
}

output "base_url" {
  value = "${aws_apigatewayv2_stage.Emperia-PDP-gateway.invoke_url}/"
}

output "env_aws_access_key" {
  value = var.env_aws_access_key
}

output "env_aws_secret_access_key" {
  value = var.env_aws_secret_access_key
}

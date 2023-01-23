
resource "aws_apigatewayv2_integration" "emperia-pdp-integration" {
  api_id           = var.api_gateway_id
  integration_type = "AWS_PROXY"

  connection_type        = "INTERNET"
  integration_method     = "POST"
  integration_uri        = var.aws_lambda_function_invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "emperia-pdp-credit-route" {
  api_id             = var.api_gateway_id
  route_key          = "POST /webhook/credit/{proxy+}"
  authorization_type = "NONE"
  target             = "integrations/${aws_apigatewayv2_integration.emperia-pdp-integration.id}"
}

resource "aws_apigatewayv2_route" "emperia-pdp-api-get-route" {
  api_id             = var.api_gateway_id
  route_key          = "GET /api/{proxy+}"
  authorization_type = "NONE"
  # authorizer_id      = aws_apigatewayv2_authorizer.emperia-pdp-gateway.id
  target             = "integrations/${aws_apigatewayv2_integration.emperia-pdp-integration.id}"
}
resource "aws_apigatewayv2_route" "emperia-pdp-docs-route" {
  api_id             = var.api_gateway_id
  route_key          = "GET /docs"
  authorization_type = "NONE"
  target             = "integrations/${aws_apigatewayv2_integration.emperia-pdp-integration.id}"
}

resource "aws_apigatewayv2_route" "emperia-pdp-redoc-route" {
  api_id             = var.api_gateway_id
  route_key          = "GET /redoc"
  authorization_type = "NONE"
  target             = "integrations/${aws_apigatewayv2_integration.emperia-pdp-integration.id}"
}

resource "aws_apigatewayv2_route" "emperia-pdp-openapi-route" {
  api_id             = var.api_gateway_id
  route_key          = "GET /openapi.json"
  authorization_type = "NONE"
  target             = "integrations/${aws_apigatewayv2_integration.emperia-pdp-integration.id}"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.aws_lambda_function_arn
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API
  source_arn = "${var.api_gateway_execution_arn}/*/*"
}

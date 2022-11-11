resource "aws_apigatewayv2_api" "emperia-pdp-gateway" {
  name          = "EmperiaPDPApiGateway-${local.stage}"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins     = ["http://*", "https://*"]
    allow_methods     = ["POST", "GET", "OPTIONS"]
    allow_headers     = ["content-type", "Authorization", "*"]
    expose_headers    = ["x-api-id", "date"]
    allow_credentials = true
    max_age           = 300
  }
}

resource "aws_apigatewayv2_stage" "emperia-pdp-gateway" {
  api_id      = aws_apigatewayv2_api.emperia-pdp-gateway.id
  name        = local.stage
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = 5000
    throttling_rate_limit  = 10000
  }
}
resource "aws_apigatewayv2_authorizer" "emperia-pdp-gateway" {
 api_id           = aws_apigatewayv2_api.emperia-pdp-gateway.id
 authorizer_type  = "JWT"
 identity_sources = ["$request.header.Authorization"]
 name             = "emperia-pdp-authorizer-${local.stage}"

 jwt_configuration {
   audience = [local.authorization_audience]
   issuer   = local.authorization_issuer
 }
}

resource "aws_apigatewayv2_integration" "emperia-pdp-integration" {
  api_id           = aws_apigatewayv2_api.emperia-pdp-gateway.id
  integration_type = "AWS_PROXY"

  connection_type        = "INTERNET"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.emperia-pdp-lambda-function.invoke_arn
  payload_format_version = "2.0"
}
resource "aws_apigatewayv2_route" "emperia-pdp-api-get-route" {
  api_id             = aws_apigatewayv2_api.emperia-pdp-gateway.id
  route_key          = "GET /api/{proxy+}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.emperia-pdp-gateway.id
  target             = "integrations/${aws_apigatewayv2_integration.emperia-pdp-integration.id}"
}

resource "aws_apigatewayv2_route" "emperia-pdp-docs-route" {
  api_id             = aws_apigatewayv2_api.emperia-pdp-gateway.id
  route_key          = "GET /docs"
  authorization_type = "NONE"
  target             = "integrations/${aws_apigatewayv2_integration.emperia-pdp-integration.id}"
}

resource "aws_apigatewayv2_route" "emperia-pdp-redoc-route" {
  api_id             = aws_apigatewayv2_api.emperia-pdp-gateway.id
  route_key          = "GET /redoc"
  authorization_type = "NONE"
  target             = "integrations/${aws_apigatewayv2_integration.emperia-pdp-integration.id}"
}

resource "aws_apigatewayv2_route" "emperia-pdp-openapi-route" {
  api_id             = aws_apigatewayv2_api.emperia-pdp-gateway.id
  route_key          = "GET /openapi.json"
  authorization_type = "NONE"
  target             = "integrations/${aws_apigatewayv2_integration.emperia-pdp-integration.id}"
}

resource "aws_apigatewayv2_route" "emperia-pdp-credit-route" {
  api_id             = aws_apigatewayv2_api.emperia-pdp-gateway.id
  route_key          = "POST /webhook/credit/{proxy+}"
  authorization_type = "NONE"
  target             = "integrations/${aws_apigatewayv2_integration.emperia-pdp-integration.id}"
}

resource "aws_apigatewayv2_api" "Emperia-PDP-gateway" {
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


#resource "aws_apigatewayv2_authorizer" "Emperia-PDP-gateway" {
#  api_id           = aws_apigatewayv2_api.Emperia-PDP-gateway.id
#  authorizer_type  = "JWT"
#  identity_sources = ["$request.header.Authorization"]
#  name             = "Emperia-PDP-authorizer-${local.stage}"

#  jwt_configuration {
#    audience = [local.authorization_audience]
#    issuer   = local.authorization_issuer
#  }
#}

resource "aws_apigatewayv2_integration" "Emperia-PDP-integration" {
  api_id           = aws_apigatewayv2_api.Emperia-PDP-gateway.id
  integration_type = "AWS_PROXY"

  connection_type        = "INTERNET"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.Emperia-PDP-lambda-function.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "Emperia-PDP-docs-route" {
  api_id             = aws_apigatewayv2_api.Emperia-PDP-gateway.id
  route_key          = "GET /docs"
  authorization_type = "NONE"
  target             = "integrations/${aws_apigatewayv2_integration.Emperia-PDP-integration.id}"
}

resource "aws_apigatewayv2_route" "Emperia-PDP-redoc-route" {
  api_id             = aws_apigatewayv2_api.Emperia-PDP-gateway.id
  route_key          = "GET /redoc"
  authorization_type = "NONE"
  target             = "integrations/${aws_apigatewayv2_integration.Emperia-PDP-integration.id}"
}

resource "aws_apigatewayv2_route" "Emperia-PDP-openapi-route" {
  api_id             = aws_apigatewayv2_api.Emperia-PDP-gateway.id
  route_key          = "GET /openapi.json"
  authorization_type = "NONE"
  target             = "integrations/${aws_apigatewayv2_integration.Emperia-PDP-integration.id}"
}

resource "aws_apigatewayv2_route" "Emperia-PDP-credit-route" {
  api_id             = aws_apigatewayv2_api.Emperia-PDP-gateway.id
  route_key          = "POST /webhook/credit/{proxy+}"
  authorization_type = "NONE"
  target             = "integrations/${aws_apigatewayv2_integration.Emperia-PDP-integration.id}"
}

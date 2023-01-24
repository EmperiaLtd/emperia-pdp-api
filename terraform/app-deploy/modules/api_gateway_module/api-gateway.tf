resource "aws_apigatewayv2_api" "emperia-pdp-gateway" {
  name          = "emperiapdpapigateway-${var.stage}"
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
  name        = var.stage
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
 name             = "emperia-pdp-authorizer-${var.stage}"

 jwt_configuration {
   audience = [var.authorization_audience]
   issuer   = var.authorization_issuer
 }
}

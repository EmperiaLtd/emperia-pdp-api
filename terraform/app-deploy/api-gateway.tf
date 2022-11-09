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


resource "aws_apigatewayv2_stage" "Emperia-PDP-gateway" {
  api_id      = aws_apigatewayv2_api.Emperia-PDP-gateway.id
  name        = local.stage
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = 5000
    throttling_rate_limit  = 10000
  }
}
resource "aws_apigatewayv2_route" "Emperia-PDP-api-get-route" {
  api_id             = aws_apigatewayv2_api.Emperia-PDP-gateway
  route_key          = "GET /"
  target             = "integrations/${aws_apigatewayv2_integration.Emperia-PDP-integration}"
}
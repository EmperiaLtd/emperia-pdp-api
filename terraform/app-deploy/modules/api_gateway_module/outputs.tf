output "api_gateway_execution_arn" {
  value = aws_apigatewayv2_api.emperia-pdp-gateway.execution_arn
}
output "api_gateway_id" {
  value = aws_apigatewayv2_api.emperia-pdp-gateway.id
}
output "base_url" {
 value = "${aws_apigatewayv2_stage.emperia-pdp-gateway.invoke_url}/"
}

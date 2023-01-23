variable "development_authorization_issuer"{
  default = "https://emperia.eu.auth0.com/"
}

variable "staging_authorization_issuer"{
    default = "https://emperia-staging.eu.auth0.com/"
}

variable "prod_authorization_issuer"{
  default = "https://emperia-production.eu.auth0.com/"
}

 variable "development_authorization_audience" {
  default = "https://emperia-pdp-jwt-authorizer"
}

 variable "staging_authorization_audience" {
  default = "https://emperia-pdp-jwt-authorizer-staging"
}

 variable "prod_authorization_audience" {
  default = "https://emperia-pdp-jwt-authorizer-production"
}

locals {
  stage                = "development"
  authorization_issuer =  terraform.workspace == "production" ? var.prod_authorization_issuer : (terraform.workspace == "staging" ? var.staging_authorization_issuer : var.development_authorization_issuer)
  authorization_audience = terraform.workspace == "production" ? var.prod_authorization_audience : (terraform.workspace == "staging" ? var.staging_authorization_audience: var.development_authorization_audience)
}

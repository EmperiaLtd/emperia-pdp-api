variable "stage" {
    description = "current working stage (development/production)"
    default = "development"
}

variable "authorization_issuer" {
    description = "Authorization Issuer"
}

variable "authorization_audience" {
  description = "Authorization Audience"
}

variable "elestio_email" {
  type = string
}

variable "elestio_api_token" {
  type      = string
  sensitive = true
}

variable "rabbitmq_pass" {
  type      = string
  sensitive = true
}

variable "erlang_cookie" {
  type      = string
  sensitive = true
}

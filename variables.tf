variable "project_id" {
  type        = string
  description = "The ID of the project in which the RabbitMQ instances will be created"
}

variable "nodes_count" {
  type        = number
  default     = 1
  description = <<-EOT
    The desired number of RabbitMQ instances.
    Minimum value: `1`.
    Maximum value: `5`.
    Default value: `1`.
  EOT

  validation {
    condition     = var.nodes_count >= 1 && var.nodes_count <= 5
    error_message = "Minimum `1`, maximum `5`."
  }
}

variable "config" {
  type = object({
    server_name   = string
    provider_name = string
    datacenter    = string
    server_type   = string
    version       = string
    support_level = string
    admin_email   = string
  })
  description = "The configuration will be applied on all RabbitMQ services."
}

variable "ssh_key" {
  type = object({
    key_name    = string
    public_key  = string
    private_key = string
  })
  description = "An SSH connection will be needed to run the bash commands on all services to create the cluster."
  sensitive   = true
}

variable "erlang_cookie" {
  type        = string
  description = <<-EOT
    A string of alphanumeric characters that is used for communication between nodes in a RabbitMQ cluster.
    The same value will be applied in environment variable `RABBITMQ_ERLANG_COOKIE` on all instances.
  EOT
  sensitive   = true
}

resource "elestio_load_balancer" "load_balancer" {
  project_id    = elestio_project.project.id
  provider_name = "hetzner"
  datacenter    = "fsn1"
  server_type   = "SMALL-1C-2G"
  config = {
    target_services = [for node in module.cluster.nodes : node.id]
    forward_rules = [
      {
        port            = "5672"
        protocol        = "TCP"
        target_port     = "5672"
        target_protocol = "TCP"
      },
    ]
  }
}

output "connection_string" {
  value     = "amqp://root:${RABBITMQ_PASS}@${elestio_load_balancer.load_balancer.cname}:5672"
  sensitive = true
}

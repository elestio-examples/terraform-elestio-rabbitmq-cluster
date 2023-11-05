module "cluster" {
  source = "elestio-examples/rabbitmq-cluster/elestio"

  project_id    = "xxxxxx"
  rabbitmq_pass = "xxxxxx"
  erlang_cookie = "xxxxxx"

  configuration_ssh_key = {
    username    = "something"
    public_key  = chomp(file("~/.ssh/id_rsa.pub"))
    private_key = file("~/.ssh/id_rsa")
  }

  nodes = [
    {
      server_name   = "rabbitmq-1"
      provider_name = "scaleway"
      datacenter    = "fr-par-1"
      server_type   = "SMALL-2C-2G"
    },
    {
      server_name   = "rabbitmq-2"
      provider_name = "scaleway"
      datacenter    = "fr-par-2"
      server_type   = "SMALL-2C-2G"
    },
  ]
}

output "nodes_admins" {
  value     = { for node in module.cluster.nodes : node.server_name => node.admin }
  sensitive = true
}

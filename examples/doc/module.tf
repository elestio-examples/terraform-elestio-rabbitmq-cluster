module "cluster" {
  source = "elestio-examples/rabbitmq-cluster/elestio"

  project_id       = elestio_project.project.id
  rabbitmq_version = null # null means latest version
  rabbitmq_pass    = "xxxxxxxxxxxxx"
  erlang_cookie    = "xxxxxxxxxxxxx"

  configuration_ssh_key = {
    username    = "terraform"
    public_key  = chomp(file("~/.ssh/id_rsa.pub"))
    private_key = file("~/.ssh/id_rsa")
  }

  nodes = [
    {
      server_name   = "rabbitmq-1"
      provider_name = "hetzner"
      datacenter    = "fsn1"
      server_type   = "SMALL-1C-2G"
    },
    {
      server_name   = "rabbitmq-2"
      provider_name = "hetzner"
      datacenter    = "fsn1"
      server_type   = "SMALL-1C-2G"
    },
  ]
}

# main.tf

module "rabbitmq-cluster" {
  source        = "elestio-examples/rabbitmq-cluster/elestio"
  nodes_count   = 3
  project_id    = var.project_id
  erlang_cookie = var.erlang_cookie
  config = {
    server_name   = "rabbitmq-example"
    server_type   = "SMALL-1C-2G"
    provider_name = "hetzner"
    datacenter    = "fsn1"
    version       = "3-management"
    support_level = "level1"
    admin_email   = var.admin_email
  }
  ssh_key = {
    key_name    = var.ssh_key_name
    public_key  = var.ssh_public_key
    private_key = var.ssh_private_key
  }
}

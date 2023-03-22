module "terraform_elestio_rabbitmq_cluster" {
  source = "elestio/terraform_elestio_rabbitmq_cluster/elestio"

  nodes_count   = 3
  project_id    = "<your-project-id>"
  erlang_cookie = "<your-secret-string>"
  config = {
    server_name   = "rabbitmq-example"
    server_type   = "SMALL-1C-2G"
    provider_name = "hetzner"
    datacenter    = "fsn1"
    version       = "3-management"
    support_level = "level1"
    admin_email   = "<your-email>"
  }
  ssh_key = {
    key_name    = "ssh_key_example"
    public_key  = file("/Users/[...]/.ssh/id_rsa.pub")
    private_key = file("/Users/[...]/.ssh/id_rsa")
  }
}

resource "elestio_rabbitmq" "nodes" {
  count         = var.nodes_count
  project_id    = var.project_id
  server_name   = "${var.config.server_name}-${count.index}"
  server_type   = var.config.server_type
  provider_name = var.config.provider_name
  datacenter    = var.config.datacenter
  version       = var.config.version
  support_level = var.config.support_level
  admin_email   = var.config.admin_email
  ssh_keys = [
    {
      key_name   = var.ssh_key.key_name
      public_key = var.ssh_key.public_key
    },
  ]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "root"
      host        = self.cname
      private_key = file("/Users/adamkrim/.ssh/id_rsa")
    }
    when = destroy
    inline = [
      count.index > 0 ? "docker exec -it rabbitmq rabbitmqctl stop_app" : "echo",
      count.index > 0 ? "docker exec -it rabbitmq rabbitmqctl reset" : "echo",
    ]
  }
}

resource "null_resource" "cluster_configuration" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    require_replace = join(",", concat([var.erlang_cookie], elestio_rabbitmq.nodes.*.id))
  }

  provisioner "local-exec" {
    command = templatefile("${path.module}/scripts/setup_cluster.sh.tftpl", {
      # filter only required values on the script
      nodes           = [for node in elestio_rabbitmq.nodes : tomap({ "id" = node.id, "ipv4" = node.ipv4, "server_name" = node.server_name, "global_ip" = node.global_ip })]
      ssh_private_key = var.ssh_key.private_key
      erlang_cookie   = var.erlang_cookie
    })
  }
}

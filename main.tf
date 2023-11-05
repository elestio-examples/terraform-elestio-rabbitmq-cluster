resource "elestio_rabbitmq" "nodes" {
  for_each = { for i, value in var.nodes : value.server_name => merge(value, { index = i }) }

  project_id       = var.project_id
  version          = var.rabbitmq_version
  default_password = var.rabbitmq_pass
  server_name      = each.value.server_name
  provider_name    = each.value.provider_name
  datacenter       = each.value.datacenter
  server_type      = each.value.server_type
  // Merge the module configuration_ssh_key with the optional ssh_public_keys attribute
  ssh_public_keys = concat(each.value.ssh_public_keys, [{
    username = var.configuration_ssh_key.username
    key_data = var.configuration_ssh_key.public_key
  }])

  // Optional attributes
  admin_email                                       = each.value.admin_email
  alerts_enabled                                    = each.value.alerts_enabled
  app_auto_updates_enabled                          = each.value.app_auto_update_enabled
  backups_enabled                                   = each.value.backups_enabled
  custom_domain_names                               = each.value.custom_domain_names
  firewall_enabled                                  = each.value.firewall_enabled
  keep_backups_on_delete_enabled                    = each.value.keep_backups_on_delete_enabled
  remote_backups_enabled                            = each.value.remote_backups_enabled
  support_level                                     = each.value.support_level
  system_auto_updates_security_patches_only_enabled = each.value.system_auto_updates_security_patches_only_enabled
}

resource "null_resource" "ensure_child_node_leaves_cluster_nicely" {
  for_each = { for server_name, node in elestio_rabbitmq.nodes : server_name => node if server_name != var.nodes[0].server_name }

  triggers = {
    ipv4            = each.value.ipv4
    ssh_private_key = var.configuration_ssh_key.private_key
  }

  connection {
    type        = "ssh"
    host        = self.triggers.ipv4
    private_key = self.triggers.ssh_private_key
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "docker exec -it rabbitmq rabbitmqctl stop_app",
      "docker exec -it rabbitmq rabbitmqctl reset",
    ]
  }
}

resource "null_resource" "cluster_configuration" {
  triggers = {
    require_replace = join(",", concat([var.erlang_cookie], [for node in elestio_rabbitmq.nodes : node.id]))
  }

  provisioner "local-exec" {
    command = templatefile("${path.module}/scripts/setup_cluster.sh.tftpl", {
      ssh_private_key = nonsensitive(var.configuration_ssh_key.private_key)
      erlang_cookie   = nonsensitive(var.erlang_cookie)
      nodes           = [for node in elestio_rabbitmq.nodes : tomap({ "id" = node.id, "ipv4" = node.ipv4, "server_name" = node.server_name, "global_ip" = node.global_ip })]
    })
    quiet = true
  }
}

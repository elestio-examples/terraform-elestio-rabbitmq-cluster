<!-- BEGIN_TF_DOCS -->
# Elestio RabbitMQ Cluster Terraform module

Using this module, you can easily and quickly deploy with **Terraform** a **RabbitMQ Cluster** on **Elestio** that is configured correctly and **ready to use**, without spending a lot of time on manual configuration.


## Module requirements

- 1 Elestio account https://dash.elest.io/signup
- 1 API key https://dash.elest.io/account/security
- 1 SSH public/private key (see how to create one [here](https://registry.terraform.io/providers/elestio/elestio/latest/docs/guides/ssh_keys))

## Usage

This is a minimal example of how to use the module:

```hcl
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
```

Keep your rabbitmq password safe, you will need it to access the admin panel.

If you want to know more about node configuration, check the rabbitmq service documentation [here](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/rabbitmq).

If you want to choose your own provider, datacenter or server type, check the guide [here](https://registry.terraform.io/providers/elestio/elestio/latest/docs/guides/providers_datacenters_server_types).

If you want to generated a valid SSH Key, check the guide [here](https://registry.terraform.io/providers/elestio/elestio/latest/docs/guides/ssh_keys).

If you add more nodes, you may attains the resources limit of your account, please visit your account [quota page](https://dash.elest.io/account/add-quota).

## Quick configuration

The following example will create a RabbitMQ cluster with 2 nodes.

You may need to adjust the configuration to fit your needs.

Create a `main.tf` file at the root of your project, and fill it with your Elestio credentials:

```hcl
terraform {
  required_providers {
    elestio = {
      source = "elestio/elestio"
    }
  }
}

provider "elestio" {
  email     = "xxxx@xxxx.xxx"
  api_token = "xxxxxxxxxxxxx"
}

resource "elestio_project" "project" {
  name = "RabbitMQ Cluster"
}
```

Now you can use the module to create rabbitmq nodes:

```hcl
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
```

To get a valid random rabbitmq password, you can use the url https://api.elest.io/api/auth/passwordgenerator

```bash
$ curl -s https://api.elest.io/api/auth/passwordgenerator
{"status":"OK","password":"631OLUxE-TtXB-H0pGYj3V"}
```

For the `erlang_cookie`, any secret string of your choice will work.

Finally, let's add some outputs to retrieve useful information:

```hcl
output "nodes_admins" {
  value     = { for node in module.cluster.nodes : node.server_name => node.admin }
  sensitive = true
}
```

You can now run `terraform init` and `terraform apply` to create your RabbitMQ cluster.
After a few minutes, the cluster will be ready to use.
You can access your outputs with `terraform output`:

```bash
$ terraform output nodes_admins
```

If you want to update some parameters, you can edit the `main.tf` file and run `terraform apply` again.
Terraform will automatically update the cluster to match the new configuration.
Please note that changing the node count requires to change the .env of existing nodes. This is done automatically by the module.

## Ready-to-deploy example

We created a RabbitMQ ready-to-deploy cluster example which creates the same infrastructure as the previous example.
You can find it [here](https://github.com/elestio-examples/terraform-elestio-rabbitmq-cluster/tree/main/examples/get_started).
Follow the instructions to deploy the example.

## How to use the cluster

Many clients support lists of hostnames that will be tried in order at connection time.

But if you need a manual workaround, you can add a load balancer in front of your nodes.
If you want the load balancer to be managed by Elestio, add the following code to your `main.tf` file:

```hcl
resource "elestio_load_balancer" "load_balancer" {
  project_id    = elestio_project.project.id
  provider_name = "scaleway"
  datacenter    = "fr-par-1"
  server_type   = "SMALL-2C-2G"
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
```

Use the following command to get the connection string:

```bash
$ terraform output connection_string
```

You can now use the connection string like this:

```js
var amqp = require('amqplib/callback_api');
amqp.connect(
  'amqp://root:[RABBITMQ_PASS]@[CNAME]:5672', // Replace this line with your connection string
  function (error0, connection) {
    if (error0) {
      throw error0;
    }
    connection.createChannel(function (error1, channel) {
      if (error1) {
        throw error1;
      }
      var queue = 'hello';
      var msg = 'Hello World!';
      channel.assertQueue(queue, {
        durable: false,
      });
      channel.sendToQueue(queue, Buffer.from(msg));
      console.log(' [x] Sent %s', msg);
    });
    setTimeout(function () {
      connection.close();
      process.exit(0);
    }, 500);
  }
);
```


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_configuration_ssh_key"></a> [configuration\_ssh\_key](#input\_configuration\_ssh\_key) | After the nodes are created, Terraform must connect to apply some custom configuration.<br>This configuration is done using SSH from your local machine.<br>The Public Key will be added to the nodes and the Private Key will be used by your local machine to connect to the nodes.<br><br>Read the guide [\"How generate a valid SSH Key for Elestio\"](https://registry.terraform.io/providers/elestio/elestio/latest/docs/guides/ssh_keys). Example:<pre>configuration_ssh_key = {<br>  username = "admin"<br>  public_key = chomp(file("\~/.ssh/id_rsa.pub"))<br>  private_key = file("\~/.ssh/id_rsa")<br>}</pre> | <pre>object({<br>    username    = string<br>    public_key  = string<br>    private_key = string<br>  })</pre> | n/a | yes |
| <a name="input_erlang_cookie"></a> [erlang\_cookie](#input\_erlang\_cookie) | A string of alphanumeric characters that is used for communication between nodes in a RabbitMQ cluster.<br>The same value will be applied on all instances. | `string` | n/a | yes |
| <a name="input_nodes"></a> [nodes](#input\_nodes) | Each element of this list will create an Elestio RabbitMQ Resource in your cluster.<br>Read the following documentation to understand what each attribute does, plus the default values: [Elestio KeyDB Resource](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/rabbitmq). | <pre>list(<br>    object({<br>      server_name                                       = string<br>      provider_name                                     = string<br>      datacenter                                        = string<br>      server_type                                       = string<br>      admin_email                                       = optional(string)<br>      alerts_enabled                                    = optional(bool)<br>      app_auto_update_enabled                           = optional(bool)<br>      backups_enabled                                   = optional(bool)<br>      custom_domain_names                               = optional(set(string))<br>      firewall_enabled                                  = optional(bool)<br>      keep_backups_on_delete_enabled                    = optional(bool)<br>      remote_backups_enabled                            = optional(bool)<br>      support_level                                     = optional(string)<br>      system_auto_updates_security_patches_only_enabled = optional(bool)<br>      ssh_public_keys = optional(list(<br>        object({<br>          username = string<br>          key_data = string<br>        })<br>      ), [])<br>    })<br>  )</pre> | `[]` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `string` | n/a | yes |
| <a name="input_rabbitmq_pass"></a> [rabbitmq\_pass](#input\_rabbitmq\_pass) | Require at least 10 characters, one uppercase letter, one lowercase letter and one number.<br>Generate a random valid password: https://api.elest.io/api/auth/passwordgenerator | `string` | n/a | yes |
| <a name="input_rabbitmq_version"></a> [rabbitmq\_version](#input\_rabbitmq\_version) | The cluster nodes must share the same rabbitmq version.<br>Leave empty or set to `null` to use the Elestio recommended version. | `string` | `null` | no |
## Modules

No modules.
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nodes"></a> [nodes](#output\_nodes) | This is the created nodes full information |
## Providers

| Name | Version |
|------|---------|
| <a name="provider_elestio"></a> [elestio](#provider\_elestio) | = 0.13.0 |
| <a name="provider_null"></a> [null](#provider\_null) | = 3.2.0 |
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_elestio"></a> [elestio](#requirement\_elestio) | = 0.13.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | = 3.2.0 |
## Resources

| Name | Type |
|------|------|
| [elestio_rabbitmq.nodes](https://registry.terraform.io/providers/elestio/elestio/0.13.0/docs/resources/rabbitmq) | resource |
| [null_resource.cluster_configuration](https://registry.terraform.io/providers/hashicorp/null/3.2.0/docs/resources/resource) | resource |
| [null_resource.ensure_child_node_leaves_cluster_nicely](https://registry.terraform.io/providers/hashicorp/null/3.2.0/docs/resources/resource) | resource |
<!-- END_TF_DOCS -->

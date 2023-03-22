# Elestio RabbitMQ Cluster

This module allows you to deploy in a few minutes a Elestio RabbitMQ cluster with linked nodes.

Choose the number of nodes you want and let terraform take care of the rest. Save a lot of time.

<!-- BEGIN_TF_DOCS -->


## Example

Create a working RabbitMQ cluster with 3 nodes

```hcl
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
```


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config"></a> [config](#input\_config) | The configuration will be applied on all RabbitMQ services. | <pre>object({<br>    server_name   = string<br>    provider_name = string<br>    datacenter    = string<br>    server_type   = string<br>    version       = string<br>    support_level = string<br>    admin_email   = string<br>  })</pre> | n/a | yes |
| <a name="input_erlang_cookie"></a> [erlang\_cookie](#input\_erlang\_cookie) | A string of alphanumeric characters that is used for communication between nodes in a RabbitMQ cluster.<br>The same value will be applied in environment variable `RABBITMQ_ERLANG_COOKIE` on all instances. | `string` | n/a | yes |
| <a name="input_nodes_count"></a> [nodes\_count](#input\_nodes\_count) | The desired number of RabbitMQ instances.<br>Minimum value: `1`.<br>Maximum value: `5`.<br>Default value: `1`. | `number` | `1` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project in which the RabbitMQ instances will be created | `string` | n/a | yes |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | An SSH connection will be needed to run the bash commands on all services to create the cluster. | <pre>object({<br>    key_name    = string<br>    public_key  = string<br>    private_key = string<br>  })</pre> | n/a | yes |
## Modules

No modules.
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nodes"></a> [nodes](#output\_nodes) | The information of each RabbitMQ cluster nodes. |
## Providers

| Name | Version |
|------|---------|
| <a name="provider_elestio"></a> [elestio](#provider\_elestio) | >= 0.7.1 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.2.0 |
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_elestio"></a> [elestio](#requirement\_elestio) | >= 0.7.1 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.2.0 |
## Resources

| Name | Type |
|------|------|
| [elestio_rabbitmq.nodes](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/rabbitmq) | resource |
| [null_resource.cluster_configuration](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
<!-- END_TF_DOCS -->

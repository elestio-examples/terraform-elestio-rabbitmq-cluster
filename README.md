# Terraform module to create a simple RabbitMQ cluster on Elestio

Using this module, you can easily and quickly deploy a **RabbitMQ Cluster** on **Elestio** that is configured correctly and **ready to use**, without spending a lot of time on manual configuration.

## What it does ?

1. Uses [official](https://hub.docker.com/_/rabbitmq/) RabbitMQ docker image.
2. Creates `N` nodes.
3. Makes sure nodes can talk to each other and create the cluster.
4. Makes sure that new nodes always join the cluster.

<!-- BEGIN_TF_DOCS -->


## How to use it ?

Copy and paste into your Terraform configuration:

```hcl
# main.tf

module "rabbitmq_cluster" {
  source        = "elestio-examples/terraform_elestio_rabbitmq_cluster/elestio"
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
```

Customize the variables in a `*.tfvars` file:
```hcl
# secrets.tfvars

project_id = "2500"
erlang_cookie = "SecureAndSecretString"
admin_email = "admin@email.com"
ssh_key_name = "Admin"
ssh_public_key = file("~/.ssh/id_rsa.pub")
ssh_private_key = file("~/.ssh/id_rsa")
```

Then run :
1. `terraform init`
2. `terraform plan -var-file="secrets.tfvars"`
3. `terraform apply -var-file="secrets.tfvars"`

## Scale the nodes

If 3 nodes are no longer enough, modify `nodes_count` to 5 in the configuration and run `terraform apply` again.
This will add 2 more nodes to the cluster.

You can also reduce the number of nodes, the excess ones will leave the cluster cleanly at the next `terraform apply`.

Changing the number of nodes or the erlang cookie requires a reboot of all nodes.</br>Note that your services may be down for a few minutes (max 3mn).


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

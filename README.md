# Elestio RabbitMQ Cluster

This module allows you to deploy in a few minutes a Elestio RabbitMQ cluster with linked nodes.
Choose the number of nodes you want and let terraform take care of the rest. Save a lot of time.

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                               | Version  |
| ------------------------------------------------------------------ | -------- |
| <a name="requirement_elestio"></a> [elestio](#requirement_elestio) | >= 0.7.1 |

## Providers

| Name                                                         | Version  |
| ------------------------------------------------------------ | -------- |
| <a name="provider_elestio"></a> [elestio](#provider_elestio) | >= 0.7.1 |
| <a name="provider_null"></a> [null](#provider_null)          | n/a      |

## Modules

No modules.

## Resources

| Name                                                                                                                         | Type     |
| ---------------------------------------------------------------------------------------------------------------------------- | -------- |
| [elestio_rabbitmq.nodes](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/rabbitmq)             | resource |
| [null_resource.cluster_configuration](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name                                                                     | Description                                                                                                                                                                                         | Type                                                                                                                                                                                                     | Default | Required |
| ------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | :------: |
| <a name="input_config"></a> [config](#input_config)                      | The configuration will be applied on all RabbitMQ services.                                                                                                                                         | <pre>object({<br> server_name = string<br> provider_name = string<br> datacenter = string<br> server_type = string<br> version = string<br> support_level = string<br> admin_email = string<br> })</pre> | n/a     |   yes    |
| <a name="input_erlang_cookie"></a> [erlang_cookie](#input_erlang_cookie) | Any private and secure string.<br>The same value will be applied in environment variable `RABBITMQ_ERLANG_COOKIE` on all instances.<br>This is a condition to link RabbitMQ instances in a cluster. | `string`                                                                                                                                                                                                 | n/a     |   yes    |
| <a name="input_nodes_count"></a> [nodes_count](#input_nodes_count)       | The desired number of RabbitMQ instances.<br>Minimum value: `1`.<br>Maximum value: `5`.<br>Default value: `1`.                                                                                      | `number`                                                                                                                                                                                                 | `1`     |    no    |
| <a name="input_project_id"></a> [project_id](#input_project_id)          | The ID of the project in which the RabbitMQ instances will be created                                                                                                                               | `string`                                                                                                                                                                                                 | n/a     |   yes    |
| <a name="input_ssh_key"></a> [ssh_key](#input_ssh_key)                   | An SSH connection will be needed to run the bash commands on all services to create the cluster.                                                                                                    | <pre>object({<br> key_name = string<br> public_key = string<br> private_key = string<br> })</pre>                                                                                                        | n/a     |   yes    |

## Outputs

| Name                                               | Description                                     |
| -------------------------------------------------- | ----------------------------------------------- |
| <a name="output_nodes"></a> [nodes](#output_nodes) | The information of each RabbitMQ cluster nodes. |

<!-- END_TF_DOCS -->

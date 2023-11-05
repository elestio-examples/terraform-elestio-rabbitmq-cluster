# Get started : RabbitMQ Cluster with Terraform and Elestio

In this example, you will learn how to use this module to deploy your own RabbitMQ cluster with Elestio.

Some knowledge of [terraform](https://developer.hashicorp.com/terraform/intro) is recommended, but if not, the following instructions are sufficient.

## Prepare the dependencies

- [Sign up for Elestio if you haven't already](https://dash.elest.io/signup)

- [Get your API token in the security settings page of your account](https://dash.elest.io/account/security)

- [Download and install Terraform](https://www.terraform.io/downloads)

  You need a Terraform CLI version equal or higher than v0.14.0.
  To ensure you're using the acceptable version of Terraform you may run the following command: `terraform -v`

## Instructions

1. Rename `terraform.tfvars.example` to `terraform.tfvars` and fill in the values.

   This file contains the sensitive values to be passed as variables to Terraform.</br>
   You should **never commit this file** with git.

2. Run terraform with the following commands:

   ```bash
   terraform init
   terraform plan # to preview changes
   terraform apply
   terraform show
   ```

3. You can use the `terraform output` command to print the output block of your main.tf file:

   ```bash
   terraform output nodes_admins
   ```

## Scaling

If 2 nodes are no longer enough after the first `terraform apply`, modify `nodes_count` to 3 in the configuration and run `terraform apply` again.
This will add 1 more nodes to the cluster.

You can also reduce the number of nodes, the excess ones will leave the cluster cleanly at the next `terraform apply`.

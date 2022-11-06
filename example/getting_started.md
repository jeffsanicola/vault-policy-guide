# Getting Started with Vault Policy Examples

## Initial Setup

1. [Download and install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
2. [Download and install Vault](https://developer.hashicorp.com/vault/tutorials/getting-started/getting-started-install)
3. [Start a dev server](https://developer.hashicorp.com/vault/tutorials/getting-started/getting-started-dev-server)
4. [Set environment variables](https://developer.hashicorp.com/vault/tutorials/getting-started/getting-started-dev-server)

## Apply the Example Terraform

1. After you clone this repository locally, cd to the `example/setup` directory
2. Execute `terraform init`
3. Execute `terraform apply -auto-approve` (this will setup users, secrets, and policies within Vault.)
4. Run through the examples
5. Execute `terraform destroy -auto-approve` (this will remove all of the items created in step 3)

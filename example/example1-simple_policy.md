# Simple Policy Example

This example demonstrates a simple policy that allows full access to KV secrets in the `kv/` path.

The Terraform files create a user, KVv2 mount, and policy that grants full access to secrets in the `kv/` path.

1. Apply the terraform
2. Log in to Vault
    >
    > ```bash
    > vault login -method=userpass username=user1
    > Password (will be hidden):
    > Success! You are now authenticated. The token information displayed below
    > is already stored in the token helper. You do NOT need to run "vault login"
    > again. Future Vault requests will automatically use this token.
    > ```
    >
3. Attempt to write a secret in a location you *do not* have rights to
    >
    > ```bash
    > vault kv put secret/my_secret password=P@ssw0rd!
    > ```
    >
4. Attempt to write a secret in a location you *do* have rights to
    >
    > ```bash
    > vault kv put kv/my_secret password=P@ssw0rd!
    > ```
    >
5. Read the secret
    >
    > ```bash
    > vault kv get kv/my_secret
    > ```
    >
6. Run a Terraform destroy to clean up the example components

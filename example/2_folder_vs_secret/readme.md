# Folder vs. Secret Policy Example

This example demonstrates the difference between a policy targeted at a specific secret vs. a policy targeted at a folder and its contents.

The Terraform files create a user, KVv1 mount, and policy that grants full access to secrets in the `kv/` path.

1. Apply the terraform
2. Log in to Vault as `user2a`
    "user2a" is only able to write a secret called "my_secrets" in the root path.
    >
    > ```bash
    > vault login -method=userpass username=user2a
    > Password (will be hidden):
    > Success! You are now authenticated. The token information displayed below
    > is already stored in the token helper. You do NOT need to run "vault login"
    > again. Future Vault requests will automatically use this token.
    > ```
    >
3. Attempt to write a secret in a location you *do* have rights to
    >
    > ```bash
    > vault write kv/my_secrets password=P@ssw0rd!
    > ```
    >
4. Attempt to write a secret in a location you *do not* have rights to
    >
    > ```bash
    > vault write kv/my_secrets/secret1 password=P@ssw0rd!
    > ```
    >
5. Log in to Vault as `user2b`
    "user2b" is able to write secrets in the "my_secrets" folder within the root path.
    >
    > ```bash
    > vault login -method=userpass username=user2a
    > Password (will be hidden):
    > Success! You are now authenticated. The token information displayed below
    > is already stored in the token helper. You do NOT need to run "vault login"
    > again. Future Vault requests will automatically use this token.
    > ```
    >
6. Attempt to read the `kv/my_secrets` secret (this will fail)
    >
    > ```bash
    > vault kv get kv/my_secret
    > ```
    >
7. Attempt to write a secret in a location you *do* have rights to
    >
    > ```bash
    > vault write kv/my_secrets/secret1 password=P@ssw0rd!
    > ```
    >
8. Run a Terraform destroy to clean up the example components

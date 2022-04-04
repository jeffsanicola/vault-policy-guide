# Policy Inheritence Example

This example demonstrates that capabilities assigned at a higher folder level do not flow down to child paths when a different capability is applied on a child path.

The Terraform files create a user, KVv1 mount, and policy that grants `list` and `read` to secrets in the `kv/example` path and `update` to the `kv/example/subfolder` path.

1. Apply the terraform
2. Log in to Vault
    >
    > ```bash
    > vault login -method=userpass username=user3
    > Password (will be hidden):
    > Success! You are now authenticated. The token information displayed below
    > is already stored in the token helper. You do NOT need to run "vault login"
    > again. Future Vault requests will automatically use this token.
    >```
    >
3. List secrets in the `kv/example` folder
    >
    > ```bash
    > vault list kv/example
    > ```
    >
4. Read the `test_secret` secret
    >
    > ```bash
    > vault read kv/example/test_secret
    > ```
    >
5. Attempt to read the `kv/example/subfolder/test_secret` secret (this will fail)
    >
    > ```bash
    > vault read kv/example/subfolder/test_secret
    >```
    >
6. Attempt to update the `kv/example/subfolder/test_secret` secret (this will succeed)
    >
    > ```bash
    > vault write kv/example/subfolder/test_secret password="P@ssw0rd!"
    > ```
    >
7. Attempt to create a new secret at `kv/example/subfolder/new_secret` (this will fail)
    >
    > ```bash
    > vault write kv/example/subfolder/new_secret password="P@ssw0rd!"
    > ```
    >
8. Run a Terraform destroy to clean up the example components

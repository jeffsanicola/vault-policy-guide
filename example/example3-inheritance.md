# Policy Inheritence Example

This example demonstrates that capabilities assigned at a higher folder level do not flow down to child paths when a different capability is applied on a child path.

The Terraform files create a user, KVv1 mount, and policy that grants `list` and `read` to secrets in the `kv/example` path and `update` to the `kv/example/subfolder` path.

1. Log in to Vault as `user3` with password "changeme"
    >
    > ```bash
    > vault login -method=userpass username=user3
    > Password (will be hidden):
    > Success! You are now authenticated. The token information displayed below
    > is already stored in the token helper. You do NOT need to run "vault login"
    > again. Future Vault requests will automatically use this token.
    >```
    >
2. List secrets in the `kv/example3` folder
    >
    > ```bash
    > vault list kv/example3
    > ```
    >
3. Read the `secret` secret
    >
    > ```bash
    > vault read kv/example3/secret
    > ```
    >
4. Attempt to read the `kv/example3/subfolder/secret` secret (this will fail)
    >
    > ```bash
    > vault read kv/example3/subfolder/secret
    >```
    >
5. Attempt to update the `kv/example3/subfolder/secret` secret (this will succeed)
    >
    > ```bash
    > vault write kv/example3/subfolder/secret password="P@ssw0rd!"
    > ```
    >
6. Attempt to create a new secret at `kv/example3/subfolder/new_secret` (this will fail)
    >
    > ```bash
    > vault write kv/example3/subfolder/new_secret password="P@ssw0rd!"
    > ```
    >

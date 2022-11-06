# Templated Policy Examples

This example demonstrates Templated policies for KVv2 secrets in the `kv/` path.

The Terraform files create a user, KVv2 mount, and policy that grants access to secrets specific to the logged in user within the `kv/` path.

## Example 8A

Users will only be able to read and write content to their respective folders.

1. Log in to Vault as `user8a` with password "changeme"
    "user8a" will be able to read/write within the "user8a" folder.
    >
    > ```bash
    > vault login -method=userpass username=user8a
    > Password (will be hidden):
    > Success! You are now authenticated. The token information displayed below
    > is already stored in the token helper. You do NOT need to run "vault login"
    > again. Future Vault requests will automatically use this token.
    > ```

2. Read the "my_secret" secret in "user8a" (this will succeed)
    >
    > ```bash
    > vault read kvv2/user8a/my_secret
    > ```

3. Update the "my_secret" secret in "user8a" (this will succeed)
    >
    > ```bash
    > vault write kvv2/user8a/secret password=P@ssw0rd!
    > ```

4. Attempt to read the "my_secret" secret in the "user8b" folder (this will fail)
    >
    > ```bash
    > vault get kvv2/user8b/secret
    > ```

## Example 8B

1. Log in to Vault as `user8b` with password "changeme"
    "user8b" will not be able to interact with anything in the "user8a" folder.
    >
    > ```bash
    > vault login -method=userpass username=user5b
    > Password (will be hidden):
    > Success! You are now authenticated. The token information displayed below
    > is already stored in the token helper. You do NOT need to run "vault login"
    > again. Future Vault requests will automatically use this token.
    > ```

2. Attempt to read the secret "my_secret" in "user8a" (this will fail)
    >
    > ```bash
    > vault write kvv2/user8a/my_secret
    > ```

3. Attempt to read the secret "my_secret" in "user8b" (this will succeed)
    >
    > ```bash
    > vault write kvv2/user8b/my_secret
    > ```

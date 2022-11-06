# Templated Policy Examples

This example demonstrates Templated policies for KVv2 secrets in the `kv/` path.

The Terraform files create a user, KVv2 mount, and policy that grants access to secrets specific to the logged in user within the `kv/` path.

## Example 6A

Users will only be able to read and write content to their respective folders.

1. Apply the terraform
2. Log in to Vault as `user6a`
    "user6a" will be able to read/write within the "user6a" folder.
    >
    > ```bash
    > vault login -method=userpass username=user6a
    > Password (will be hidden):
    > Success! You are now authenticated. The token information displayed below
    > is already stored in the token helper. You do NOT need to run "vault login"
    > again. Future Vault requests will automatically use this token.
    > ```

3. Read the "my_secret" secret in "user6a" (this will succeed)
    >
    > ```bash
    > vault read kv/user1/my_secret
    > ```

4. Update the "my_secret" secret in "user6a" (this will succeed)
    >
    > ```bash
    > vault write kv/user6a/secret password=P@ssw0rd!
    > ```

5. Attempt to read the "my_secret" secret in the "user6b" folder (this will fail)
    >
    > ```bash
    > vault get kv/user6b/secret
    > ```

6. Log in to Vault as `user6b`
    "user6b" will not be able to interact with anything in the "user6a" folder.
    >
    > ```bash
    > vault login -method=userpass username=user5b
    > Password (will be hidden):
    > Success! You are now authenticated. The token information displayed below
    > is already stored in the token helper. You do NOT need to run "vault login"
    > again. Future Vault requests will automatically use this token.
    > ```

7. Attempt to read the secret "my_secret" in "user6a" (this will fail)
    >
    > ```bash
    > vault write kv/user6a/my_secret
    > ```

8. Attempt to read the secret "my_secret" in "user6b" (this will succeed)
    >
    > ```bash
    > vault write kv/user6b/my_secret
    > ```

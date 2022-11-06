# KV Policy Examples

This example demonstrates various policies for KV secrets in the `kv/` and `kvv2` paths.

The Terraform files create a user, KVv1 mount, KVv2 mount, and policies that grant varying levels of access to secrets in the `kv/` and `kvvs` paths.

## Example 6A

Two policies applied to the same exact path provide the cumulative permission set.

1. Log in to Vault as `user6a`
    "user6a" will be able to write within specific subfolder of the root path and in some cases additional restrictions are applied.
    >
    > ```bash
    > vault login -method=userpass username=user6a
    > Password (will be hidden):
    > Success! You are now authenticated. The token information displayed below
    > is already stored in the token helper. You do NOT need to run "vault login"
    > again. Future Vault requests will automatically use this token.
    > ```
    >
2. Read the "my_secret" secret in "folder1" (this will succeed)
    >
    > ```bash
    > vault read kv/folder1/my_secret
    > ```
    >
3. Update the "my_secret" secret in "folder1" (this will succeed)
    >
    > ```bash
    > vault write kv/folder1/secret password=P@ssw0rd!
    > ```
    >

## Example 6B

The deny permission takes priority over any other permissions.

1. Log in to Vault as `user6b`
    "user6b" will not be able to interact with anything in the "folder1" folder.
    >
    > ```bash
    > vault login -method=userpass username=user6b
    > Password (will be hidden):
    > Success! You are now authenticated. The token information displayed below
    > is already stored in the token helper. You do NOT need to run "vault login"
    > again. Future Vault requests will automatically use this token.
    > ```
    >
2. Attempt to read the secret "my_secret" in "folder5" (this will fail)
    >
    > ```bash
    > vault write kv/folder5/my_secret password=P@ssw0rd!
    > ```

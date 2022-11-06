# KV Policy Examples

This example demonstrates various policies for KV secrets in the `kv/` and `kvv2` paths.

The Terraform files create a user, KVv1 mount, KVv2 mount, and policies that grant varying levels of access to secrets in the `kv/` and `kvvs` paths.

## Example 6A

User6a has full control over KVv1 secrets in the `kv` mount.

1. Log in to Vault as `user6a` with password "changeme"
    "user6a" will be able to read and write within the `kv` mount.
    >
    > ```bash
    > vault login -method=userpass username=user6a
    > Password (will be hidden):
    > Success! You are now authenticated. The token information displayed below
    > is already stored in the token helper. You do NOT need to run "vault login"
    > again. Future Vault requests will automatically use this token.
    > ```

2. Read the "my_secret" secret in "folder1" (this will succeed)
    >
    > ```bash
    > vault read kv/6a/my_secret
    > ```

3. Update the "my_secret" secret in "folder1" (this will succeed)
    >
    > ```bash
    > vault write kv/folder1/secret password=P@ssw0rd!
    > ```

## Example 6B

User6b has read-only access to KVv1 secrets in the `kv` mount.

1. Log in to Vault as `user6b` with password "changeme"
    "user6b" will only be able to list and read secrets within the `kv` mount.
    >
    > ```bash
    > vault login -method=userpass username=user6b
    > Password (will be hidden):
    > Success! You are now authenticated. The token information displayed below
    > is already stored in the token helper. You do NOT need to run "vault login"
    > again. Future Vault requests will automatically use this token.
    > ```

2. List the secrets in the `kv` mount.
    >
    > ```bash
    > vault list kv
    > ```

3. Read the `my_secret` secret in the `example6` folder (this will succeed)
    >
    > ```bash
    > vault read kv/example6/my_secret
    > ```

4. Attempt to update the `my_secret` secret in the `example6` folder (this will fail)
    >
    > ```bash
    > vault write kv/example6/my_secret password="P@ssw0rd"
    > ```

## Example 6C

User6c has full access to KVv2 secrets in the `kvv2` mount.

1. Log in to Vault as `user6c` with password "changeme"
    "user6c" will be able to read and write within the `kvv2` mount.
    >
    > ```bash
    > vault login -method=userpass username=user6c
    > Password (will be hidden):
    > Success! You are now authenticated. The token information displayed below
    > is already stored in the token helper. You do NOT need to run "vault login"
    > again. Future Vault requests will automatically use this token.
    > ```

2. List the secrets in the `kvv2` mount.
    >
    > ```bash
    > vault kv list -mount=kvv2
    > ```

3. Read the `my_secret` secret in the `example6c` folder (this will succeed)
    >
    > ```bash
    > vault kv get -mount=kvv2 example6c/my_secret
    > ```

4. Update the `my_secret` secret in the `example6c` folder (this will succeed)
    >
    > ```bash
    > vault kv put -mount=kvv2 example6c/my_secret password="P@ssw0rd"
    > ```

5. Refer to the [KVv2 documentation](https://developer.hashicorp.com/vault/docs/secrets/kv/kv-v2) for further examples of deleting, undeleting, and destroying secrets.

## Example 6D

1. Log in to Vault as `user6d` with password "changeme"
    "user6d" will be able to list and read within the `kvv2` mount.
    >
    > ```bash
    > vault login -method=userpass username=user6c
    > Password (will be hidden):
    > Success! You are now authenticated. The token information displayed below
    > is already stored in the token helper. You do NOT need to run "vault login"
    > again. Future Vault requests will automatically use this token.
    > ```

2. List the secrets in the `kvv2` mount.
    >
    > ```bash
    > vault kv list -mount=kvv2
    > ```

3. Read the `my_secret` secret in the `example6c` folder (this will succeed)
    >
    > ```bash
    > vault kv get -mount=kvv2 example6c/my_secret
    > ```

4. Update the `my_secret` secret in the `example6c` folder (this will fail)
    >
    > ```bash
    > vault kv put -mount=kvv2 example6c/my_secret password="P@ssw0rd"
    > ```

## Observations

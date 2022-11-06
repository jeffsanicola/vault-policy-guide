# Conflicting Policy Examples

This example demonstrates various conflicting policies for KV secrets in the `kv/` path.

The Terraform files create a user, KVv1 mount, and policy that grants varying levels of access to secrets in the `kv/` path.

## Example 5A

Two policies applied to the same exact path provide the cumulative permission set.

1. Log in to Vault as `user5a` with password "changeme"
    "user5a" will be able to write within specific subfolder of the root path and in some cases additional restrictions are applied.
    >
    > ```bash
    > vault login -method=userpass username=user5a
    > Password (will be hidden):
    > Success! You are now authenticated. The token information displayed below
    > is already stored in the token helper. You do NOT need to run "vault login"
    > again. Future Vault requests will automatically use this token.
    > ```

2. Read the "my_secret" secret in "folder1" (this will succeed)
    >
    > ```bash
    > vault read kv/folder1/my_secret
    > ```

3. Update the "my_secret" secret in "folder1" (this will succeed)
    >
    > ```bash
    > vault write kv/folder1/secret password=P@ssw0rd!
    > ```

## Example 5B

The deny permission takes priority over any other permissions.

1. Log in to Vault as `user5b` with password "changeme"
    "user5b" will not be able to interact with anything in the "folder1" folder.
    >
    > ```bash
    > vault login -method=userpass username=user5b
    > Password (will be hidden):
    > Success! You are now authenticated. The token information displayed below
    > is already stored in the token helper. You do NOT need to run "vault login"
    > again. Future Vault requests will automatically use this token.
    > ```

2. Attempt to read the secret "my_secret" in "folder5" (this will fail)
    >
    > ```bash
    > vault write kv/folder5/my_secret password=P@ssw0rd!
    > ```

## Example 5C

A specific policy that grants read access on "kv/folder1/\*" will take priority over a wildcarded path of "+/folder1/\*" that grants read/write access.

1. Log in to Vault as `user5c` with password "changeme"
    "user5bc will not be able to interact with anything in the "folder1" folder.
    >
    > ```bash
    > vault login -method=userpass username=user5c
    > Password (will be hidden):
    > Success! You are now authenticated. The token information displayed below
    > is already stored in the token helper. You do NOT need to run "vault login"
    > again. Future Vault requests will automatically use this token.
    > ```

2. Attempt to read the "my_secret" secret in the "folder1" subfolder of the root path (this will succeed)
    >
    > ```bash
    > vault read kv/folder1/my_secret
    > ```

3. Attempt to update the "my_secret" secret within the "folder1" subfolder (this will fail)
    >
    > ```bash
    > vault write kv/folder1/my_secret password=P@ssw0rd!
    > ```

4. Attempt to create the "my_secret" secret within the "folder1" subfolder on the "kv-test" KV secret mount (this will succeed)
    >
    > ```bash
    > vault write kv-test/folder1/my_secret password=P@ssw0rd!
    > ```

## Example 5D

A policy that requires a specific KV mount will take priority over a policy with a wildcard mount and specific folder.

1. Log in to Vault as `user5d` with password "changeme"
    "user5d" will be able to write any secret in any subfolder of the KV root but will be unable to write directly to the root path.
    >
    > ```bash
    > vault login -method=userpass username=user5d
    > Password (will be hidden):
    > Success! You are now authenticated. The token information displayed below
    > is already stored in the token helper. You do NOT need to run "vault login"
    > again. Future Vault requests will automatically use this token.
    > ```

2. Attempt to read the "my_secret" secret within the "folder1" subfolder (this will succeed)
    >
    > ```bash
    > vault write kv/folder/my_secret password=P@ssw0rd!
    > ```

3. Attempt to update the "my_secret" secret within the "folder1" subfolder (this will fail)
    >
    > ```bash
    > vault write kv/folder1/my_secret password=P@ssw0rd!
    > ```

4. Attempt to write the "my_secret" secret within the "folder1" subfolder in the "kv-test" mount (this will succeed)
    >
    > ```bash
    > vault write kv-test/folder1/my_secret password=P@ssw0rd!
    > ```

## Observations

* Policies that overlap using the same exact path will provide the cumulative set of capabilities
* Most specific paths win
* `deny` capability take priority over all other capabilities

## Policy

View the policies in Vault:

* user5a_policy
* user5a_addon_policy
* user5b_policy
* user5b_addon_policy
* user5c_policy
* user5c_addon_policy
* user5d_policy
* user5d_addon_policy

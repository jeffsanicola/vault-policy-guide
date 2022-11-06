# Templated Policy Examples

This example demonstrates [Templated Policies](https://developer.hashicorp.com/vault/docs/concepts/policies#templated-policies) for KVv2 secrets in the `kvv2/` path. This can also be applied to KVv1 or other paths, if desired.

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
    > vault kv get -mount=kvv2 user8a/my_secret
    > ```

3. Update the "my_secret" secret in "user8a" (this will succeed)
    >
    > ```bash
    > vault kv put -mount=kvv2 user8a/secret password=P@ssw0rd!
    > ```

4. Attempt to read the "my_secret" secret in the "user8b" folder (this will fail)
    >
    > ```bash
    > vault get -mount=kvv2 user8b/secret
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
    > vault kv get -mount=kvv2 user8a/my_secret
    > ```

3. Attempt to read the secret "my_secret" in "user8b" (this will succeed)
    >
    > ```bash
    > vault kv get -mount=kvv2 user8b/my_secret
    > ```

## Observations

* Templated policies allow for a high degree of flexibility while also minimizing the number of policies that need to be authored.
* Using Identity Group attributes requires defining the specific group within the policy reference.
* If an entity has a policy assigned with a group reference that they are not a member of, the permissions are not applied.

## Setting up Access

In this case we used the `{{identity.entity.name}}` reference as seen below in the rendered policy:

```hcl
# allow list on kv
path "kvv2/metadata/" {
  capabilities = ["read", "list"]
}

# allow managing metadata
path "kvv2/metadata/{{identity.entity.name}}/*" {
  capabilities = ["read", "update", "delete", "list", "patch"]
}

# allow full control on kvv2/{{identity.entity.name}}
path "kvv2/data/{{identity.entity.name}}/*" {
  capabilities = ["create", "read", "update", "delete", "patch"]
}

# allow delete on kvv2/{{identity.entity.name}}
path "kvv2/delete/{{identity.entity.name}}/*" {
  capabilities = ["update"]
}

# allow undelete on kvv2/{{identity.entity.name}}
path "kvv2/undelete/{{identity.entity.name}}/*" {
  capabilities = ["update"]
}

# allow destroy on kvv2/{{identity.entity.name}}
path "kvv2/destroy/{{identity.entity.name}}/*" {
  capabilities = ["update"]
}
```

Be sure to review and leverage the other references available in the official [Templated Policies](https://developer.hashicorp.com/vault/docs/concepts/policies#templated-policies) guide.

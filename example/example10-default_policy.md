# Modifying the Default Policy

The `default` policy can be managed and modified by an entity with access to update the contents of the `sys/policies/acl` or `sys/policy` endpoints.

## Example 10

You have discovered that allowing entities to [generate random bytes](https://developer.hashicorp.com/vault/api-docs/system/tools#generate-random-bytes) through Vault is a common use case and want to make it available to all entities logging into Vault.

1. Log in to Vault as `user10` with password "changeme"
    "user10" will be not able to generate random bytes.
    >
    > ```bash
    > vault login -method=userpass username=user10
    > Password (will be hidden):
    > Success! You are now authenticated. The token information displayed below
    > is already stored in the token helper. You do NOT need to run "vault login"
    > again. Future Vault requests will automatically use this token.
    >```

2. Attempt to generate random bytes (this will fail)
    >
    > ```bash
    > vault write sys/tools/random format=base64
    >```

3. After reading the Generate Random Bytes documentation you determine the following needs to be added to the `default` policy:

    ```hcl
    path "sys/tools/random/*" {
        capabilities = ["update]
    }
    ```

4. In the example/setup folder, open the `example10.tf` file and change the `vault_policy` resource from:

    ```hcl
    resource "vault_policy" "default" {
      name   = "default"
      policy = local.default_policy
      #policy = local.default_policy_modified
    }
    ```

    to

    ```hcl
    resource "vault_policy" "default" {
      name   = "default"
      #policy = local.default_policy
      policy = local.default_policy_modified
    }
    ```

5. Run `terraform plan`
  
    You should note the following in the plan output:

    ```txt
            + path "sys/tools/random/*" {
            +     capabilities = ["update]
            + }
    ```

6. Run `terraform apply` to apply the changes.
7. Log in to Vault as `user10` with password "changeme"
    "user10" will now be able to generat random bytes.
    >
    > ```bash
    > vault login -method=userpass username=user10
    > Password (will be hidden):
    > Success! You are now authenticated. The token information displayed below
    > is already stored in the token helper. You do NOT need to run "vault login"
    > again. Future Vault requests will automatically use this token.
    > ```

8. Generate random bytes (this will succeed)
    >
    > ```bash
    > vault write sys/tools/random format=base64
    >```

## Default Policy as of Vault 1.12

This policy is hard coded in the Vault source code. However, it can be adjusted to suit your needs. The original `default` policy is provided here as reference but can easily be retrieved by running a dev instance of Vault.

```hcl
# Allow tokens to look up their own properties
path "auth/token/lookup-self" {
    capabilities = ["read"]
}

# Allow tokens to renew themselves
path "auth/token/renew-self" {
    capabilities = ["update"]
}

# Allow tokens to revoke themselves
path "auth/token/revoke-self" {
    capabilities = ["update"]
}

# Allow a token to look up its own capabilities on a path
path "sys/capabilities-self" {
    capabilities = ["update"]
}

# Allow a token to look up its own entity by id or name
path "identity/entity/id/{{identity.entity.id}}" {
  capabilities = ["read"]
}
path "identity/entity/name/{{identity.entity.name}}" {
  capabilities = ["read"]
}


# Allow a token to look up its resultant ACL from all policies. This is useful
# for UIs. It is an internal path because the format may change at any time
# based on how the internal ACL features and capabilities change.
path "sys/internal/ui/resultant-acl" {
    capabilities = ["read"]
}

# Allow a token to renew a lease via lease_id in the request body; old path for
# old clients, new path for newer
path "sys/renew" {
    capabilities = ["update"]
}
path "sys/leases/renew" {
    capabilities = ["update"]
}

# Allow looking up lease properties. This requires knowing the lease ID ahead
# of time and does not divulge any sensitive information.
path "sys/leases/lookup" {
    capabilities = ["update"]
}

# Allow a token to manage its own cubbyhole
path "cubbyhole/*" {
    capabilities = ["create", "read", "update", "delete", "list"]
}

# Allow a token to wrap arbitrary values in a response-wrapping token
path "sys/wrapping/wrap" {
    capabilities = ["update"]
}

# Allow a token to look up the creation time and TTL of a given
# response-wrapping token
path "sys/wrapping/lookup" {
    capabilities = ["update"]
}

# Allow a token to unwrap a response-wrapping token. This is a convenience to
# avoid client token swapping since this is also part of the response wrapping
# policy.
path "sys/wrapping/unwrap" {
    capabilities = ["update"]
}

# Allow general purpose tools
path "sys/tools/hash" {
    capabilities = ["update"]
}
path "sys/tools/hash/*" {
    capabilities = ["update"]
}

# Allow checking the status of a Control Group request if the user has the
# accessor
path "sys/control-group/request" {
    capabilities = ["update"]
}

# Allow a token to make requests to the Authorization Endpoint for OIDC providers.
path "identity/oidc/provider/+/authorize" {
 capabilities = ["read", "update"]
}
```

# Admin Policy Example

This example demonstrates the creation of an admin policy that grants access for troubleshooting while preventing access to secrets.

The Terraform files create a user, KVv2 mount, and policy that grants access to troubleshoot various components within Vault.

> **Note**
>
> The included policy, while mostly comprehensive, may not be suitable for your environment.
>
> Review the settings and make any necessary adjustments if you wish to use this policy as reference.
>
> Like any policy you create, admin policies should grant the minimum required access to perform the needed activities.

The policy included in this example allows for managing auth and secret mounts but does not allow reading KV secrets or generating dynamic credentials.

> **Warning**
>
> This example policy may also create some undesired effects, particularly around KVv1 secrets.
>
> Take the following rule:
>
> ```hcl
>  rule {
>    path         = "+/config/*"
>    capabilities = ["read", "update", "delete", "list"]
>    description  = "Allow managing secret engine configs"
>  }
> ```
>
> If a KVv1 mount is configured, this policy would allow reading, updating, and deleting the contents of any secret within the "config" directory (e.g., `kv/config/*`).
>
> There are other similar rules in this example policy. Review it thoroughly to understand the capabilities being granted.

## Example 7

Admin policy created and granted to "user7"

1. Log in to Vault as `user7` with password "changeme"
    "user7" will be able to perform most operations within Vault except viewing the full contents of secrets.
    >
    > ```bash
    > vault login -method=userpass username=user7
    > Password (will be hidden):
    > Success! You are now authenticated. The token information displayed below
    > is already stored in the token helper. You do NOT need to run "vault login"
    > again. Future Vault requests will automatically use this token.
    > ```
    >
2. Read the "my_secret" secret (this will fail)
    >
    > ```bash
    > vault kv get -mount=kvvs example7/my_secret
    > ```
    >
3. Enable the AppRole auth mount (this will succeed)
    >
    > ```bash
    > vault auth enable approle
    > ```

4. Create an AppRole role (this will succeed)
    >
    > ```bash
    > vault write auth/approle/role/my_role policies=default
    > ```

5. Disable the AppRole auth mount (this will succeed)
    >
    > ```bash
    > vault auth disable approle
    > ```

## Observations

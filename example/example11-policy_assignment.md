# Policy Assignment

Policies may be assigned in various ways to support the flexibility required by your particular implementation of Vault.

This example will focus on assigning policies to Users/Roles, Identity Entities, and Identity Groups.

For information regarding assigning policies to Tokens see the Tokens [documentation](https://developer.hashicorp.com/vault/docs/auth/token) and [API](https://developer.hashicorp.com/vault/api-docs/auth/token#create-token) guide.

## Example 11

1. Log in to Vault as `user11` with password "changeme"
    "user11" will be able to list and read within the `kvv2` mount.
    >
    > ```bash
    > vault login -method=userpass username=user6c
    > Password (will be hidden):
    > Success! You are now authenticated. The token information displayed below
    > is already stored in the token helper. You do NOT need to run "vault login"
    > again. Future Vault requests will automatically use this token.
    > ```

2. View the policies assigned to `user11`
    >
    > ```bash
    > vault token lookup
    > ```

   Output similar to the following will be display:

    > ```bash
    > Key                            Value
    > ---                            -----
    > accessor                       <redacted>
    > creation_time                  1667765687
    > creation_ttl                   768h
    > display_name                   userpass-user11
    > entity_id                      080d39ce-41d3-974a-dda9-be6878c4f53a
    > expire_time                    2022-12-08T14:14:47.0250374-06:00
    > explicit_max_ttl               0s
    > external_namespace_policies    map[]
    > id                             hvs.<redacted>
    > identity_policies              [entity11_policy group11_policy]
    > issue_time                     2022-11-06T14:14:47.0250374-06:00
    > meta                           map[username:user11]
    > num_uses                       0
    > orphan                         true
    > path                           auth/userpass/login/user11
    > policies                       [default user11_policy]
    > renewable                      true
    > ttl                            767h59m48s
    > type                           service
    > ```

3. Notice the `identity_policies` field contains `entity11_policy` and `group11_policy` and the `policies` field only contains `default` and `user11_policy`. Both fields need to be taken into consideration when troubleshooting Identity based policy assignment.

## Observations

* Policies can be assigned on the User/Role, Identity Entity, or Identity Group
* The `vault token lookup` command displays the policies assigned to the current token
* If a policy is added after initial login a new token will need to be created to use the new policies
* If a policy is modified after initial login the new capabilities will take effect immediately
* Policies assigned to groups offer much more flexible management via Terraform

## Policies

View the policies in Vault:

* user11_policy
* entity11_policy
* group11_policy

## Identity Settings

Also explore the Identity secrets (Access tab in the GUI) to see the association of the Entities to Groups.

# Vault ACL Policies

After struggling a bit with [ACL policies](https://www.vaultproject.io/docs/concepts/policies) early on in my experience with HashiCorp Vault and helping newcomers to Vault in the [community forums](https://discuss.hashicorp.com/c/vault/30), I decided to put together some practical policy examples for others to learn from. I'd recommend reading HashiCorp's [official documentation](https://www.vaultproject.io/docs/concepts/policies) as it has a lot of useful information.

This document reflects my own experiences and is not endorsed by HashiCorp in anyway. Use this information at your own risk.

- [ACL Policy Overview](#acl-policy-overview)
  - [What do ACL policies do?](#what-do-acl-policies-do)
  - [Policy Construction](#policy-construction)
- [Policy Pathing](#policy-pathing)
  - [Folders vs. Endpoints](#folders-vs-endpoints)
  - [Inheritance](#inheritance)
  - [Wildcards](#wildcards)
  - [Conflicting Policies](#conflicting-policies)
  - [Templated Policies](#templated-policies)
- [Policy Design](#policy-design)
  - [Adminstrator Policies](#adminstrator-policies)
  - [KV Policies](#kv-policies)
  - [GUI Friendly Policies](#gui-friendly-policies)
  - [Default Policy](#default-policy)
- [Policy Assignment](#policy-assignment)

## ACL Policy Overview

### What do ACL policies do?

Vault's Access Control List (ACL) policies specify a set of rules to apply to one or more paths. Policies, by themselves, do nothing. Policies are only meaningful when assigned to a token, entity, or group.

> **Helpful Hint!**
>
> ACL policies are "default deny", meaning that access is not granted unless explicity defined in an assigned policy.
>
> Use this to your advantage when designing for "least privileged" access.

### Policy Construction

Policies are written in HashiCorp Configuration Language (HCL) files. Basic policies consist of three things:

- A name (must be lower-case)
- A path (case sensitive)
- One or more "capabilities"

Paths must match valid folders or [API](https://www.vaultproject.io/api-docs) endpoints to be effective.

> **Helpful Hint!**
>
> HashiCorp's documentation often uses default names for secret engine mounts (e.g., `secret`).
>
>> **Note**
>>
>> I often see Vault novices assume that `secret` is a root path for all secret engine mounts, which is incorrect. The name you provide for your secret engine mount is the root of your ACL path.
>
> If you customize your secret mount (e.g., `kv` or `my_kv`, etc.) then you need to make the corrsponding changes in your ACL policies.
>
> ```hcl
> path "kv/*" { # <-- Use your chosen secret mount name here
>   capabilities = ["create", "read", "update" "delete", "list"]  
> }
>```

Capabilities are a superset of CRUD operations:

- `create` - allows the creation of a resource that doesn't currently exist
- `read` - allows reading or listing of a particular resource or collection of resources
- `update` - allows the updating of an already existing resource
- `delete` - allows the removal of resource
- `list` - allows for listing the content of a folder
- `deny` - disallows access to the endpoint or folder - **avoid using this unless absolutely required**
- `sudo` - allows for elevating privilege for specific commands (only required in a small subset of endpoints) - As a general rule, eliminate the use of `sudo` in your user policies unless absolutely required.

> **Example**
>
> ```hcl
> # Allow reading and writing of any secret within the "secret" mount
> path "secret/*" {
>   capabilities = ["create", "read", "update", "delete", "list"]
> }
> ```
>
> **Note:** See [KV Policies](#kv-policies) section below for guidance around KVv1 and KVv2 policies.

More advanced policies, such as [Fine-Grained Control Policies](https://www.vaultproject.io/docs/concepts/policies#fine-grained-control), can control which attributes can be written to as well as some limited content enforcement. Fine-Grained policies may only be applied to key/value pair type attributes. Anything that accepts a "map" of data, such as KVv2 ironically enough, cannot be controlled using this method. Rather [Sentinel policies](https://www.vaultproject.io/docs/enterprise/sentinel), a Vault Enterprise feature, must be used to control content directly within Vault, or content enforcement can be built into your workflow, if feasible.

## Policy Pathing

### Folders vs. Endpoints

API endpoints that end with a `/` are considered a folder and only require the `read` or `list` capabilities.  
Other endpoints will usually accept `create`, `read`, `update`, and `delete`. Some endpoints may require `sudo` for related commands to succeed, like the `sys/audit/*` endpoints. However, some endpoints only support a subset of these functions. Consult the [API guide](https://www.vaultproject.io/api-docs/index) for specific capabilities applicable to the path in question.

When referencing the [API guide](https://www.vaultproject.io/api-docs/index) you'll come across different REST methods: `GET`, `PATCH`, `POST`, `PUT`, `DELETE`, and `LIST`. Their capability equivalents are as follows:

| REST Method | Capability     |
| ----------- | -------------- |
| GET         | read           |
| PATCH       | update         |
| POST        | create, update |
| PUT         | create, update |
| DELETE      | delete         |
| LIST        | list           |

> **Helpful Hint!**
>
> The `LIST` method is supported by select utilities, such as `curl`. Other utilities, such as PowerShell's Invoke-RestMethod only support the `GET` method. To list a folder where `LIST` isn't supported, use the `GET` method and append `?list=true` to the URI.

Small differences in paths can make big differences in access. Consider the paths and associated implications in this example policy:

```hcl
# Allow reading and writing of the "abc" secret directly within the secret mount
# Listing is not possible on this path
path "secret/abc" {
  capabilities = ["create", "read", "update", "delete"]
}

# Allow listing of the "abc" folder within the secret mount (the trailing / makes this a folder, not a secret)
# The other operations are not possible on this path
path "secret/abc/" {
  capabilities = ["list"]
}

# Allow managing of all secrets within the "abc" folder
# The * character represents 0 or more characters
# This makes the previous rule redundant
# This WILL NOT allow reading of the "secret/abc" secret
path "secret/abc/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
```

### Inheritance

Policy inheritance doesn't really exist in Vault. However, if you're like me when I started out, you may have some bad assumptions derived from experience with other products. Remember: *the most specific ACL path wins*.

Consider the following policy:

```hcl
# Allow read and list access on secrets in "abc" folder
path "secret/abc/*" {
  capabilities = ["read", "list"]
}

# Allow write access in "abc/123" folder
path "secret/abc/123/*" {
  capabilities = ["update"]
}
```

**Q:** If you try to read `secret/abc/123/my_secret`, what will happen?  
**A:** If you said you'll get a 403 Access Denied, you'd be right!

The `update` capability on the more specific path takes priority over the `read` and `list` capabilities on the parent path.

To visualize this a bit, consider the folder structure in the ACL and the associated capabilities:

```txt
secret/
  - abc/ # <-- have `read` and `list` access here
    - 123/ # <-- have `update` only access here
      - my_secret # <-- only able to update
```

**Q:** Now what if you try to write to `secret/abc/123/my_secret`?  
**A:** If a secret already exists, the call will succeed. Otherwise a 403 will be returned.

Vault applies the most specific policy that matches the path. Policies **do not** accumulate as you traverse the folder structure.

> **Helpful Hint!**
>
>> **Note**
>>
>> As of version 1.9, HashiCorp Vault does not support Access Based Enumeration (ABE). You can restrict which folders or secrets a token can access within a folder. Listing, however, is all-or-nothing within a particular folder.  
>> If this is unacceptable in your environment, then consider setting up multiple KV mounts or [Namespaces](https://www.vaultproject.io/docs/enterprise/namespaces). Secret engine mounts are hidden by default if your token does not have explicit access to view all mounts.  
>>
>> ***Important!*** Keep in mind that there are a [finite number of mounts](https://www.vaultproject.io/docs/internals/limits#mount-point-limits) that can be created.
>
> If you want to be able to list folders in the `abc` folder but also write secrets in the `123` folder, then a policy like the following would be required:
>
> ```hcl
> # Allow listing content in the secret mount.
> path "secret/" {
>   capabilities = [ "list"]
> }
>
> # Allow listing of secrets in the abc folder
> path "secret/abc/" {
>   capabilities = ["list"]
> }
>
> # Allow reading and writing of secrets in the abc/123 folder
> path "secret/abc/123/*" {
>   capabilities = ["create", "read", "update", "delete", "list"]
> }
> ```

### Wildcards

The `*` character may look and behave like a traditional wildcard at first, however it's actually what's called a "glob" character and may only be used at the end of a path.

- Valid - `secret/abc/*` - Allows access to any secret of folder within the `abc` folder
- Valid - `secret/abc/1*` - Allows access to any secret or folder with a name beginning with `1` within the `abc` folder
- Invalid - `secret/*/123` - The glob character is only allowed at the end of a path
- Invalid - `secret/a*c` - The glob character is only allowed at the end of a path

There is another option that behaves a bit more like a traditional wildcard in that it can be placed elsewhere in the path: the `+` character. The `+` character can substitute any full path component but not other partial parts of a path. The `+` character may also be used at the end of a path.

- Valid - `secret/+/123` - Allows access to the `123` secret in any single parent folder (i.e., A secret `secret/abc/def/123` would not be allowed)
- Valid - `secret/abc/+` - Allows access to any secret directly in the `abc` folder
- Valid - `secret/+/*` - Allows access to any secret that exists in any subfolder of the secret engine mount.
- Valid - `+/abc/123` - Allows access to secret `abc/123` in any secret engine mount.
- Invalid - `secret/ab+/*` - The `+` character must be the only character between the `/`'s.

### Conflicting Policies

In general, there are a few rules to keep in mind:

- The most specific policy will take priority
- If two policies are the same specificity then the resulting capabilities will be cumulative
- The `deny` capability takes priority over all other capabilities

Suppose you have multiple policies assigned to your token with different capabilities, what would happen?

Let's look at a few examples:

> **Example 1**
>
> ```hcl
> path "secret/abc/123/*" {
>   capabilities = ["read"]
> }
> ```
>
> and
>
> ```hcl
> path "secret/abc/123/*" {
>   capabilities = ["update"]
> }
> ```

If both of these policies are applied then the token is able to perform the cumulative actions provided in the policies - `read` and `update`, in this case.

> **Example 2**
>
> ```hcl
> path "secret/abc/123/*" {
>   capabilities = ["read"]
> }
> ```
>
> and
>
> ```hcl
> path "secret/abc/123/*" {
>   capabilities = ["deny"]
> }
> ```

In this case the `deny` capability takes priority over any other capability in this path and any interaction will result in a 403 error.

> **Example 3**
>
> ```hcl
> path "secret/abc/*" {
>   capabilities = ["read"]
> }
> ```
>
> and
>
> ```hcl
> path "+/abc/*" {
>   capabilities = ["create", "read", "update", "delete"]
> }
> ```

The `read` capability would win in this case as it is the most specific policy.

> **Example 4**
>
> ```hcl
> path "secret/+/*" {
>   capabilities = ["read"]F
> }
> ```
>
> and
>
> ```hcl
> path "+/abc/*" {
>   capabilities = ["create", "read", "update", "delete"]
> }
> ```

The `read` capability would also win in this case as it is still the most specific policy. The `+` wildcard at the beginning of the second path makes it less specific as it can apply to any mount as opposed to only the "secret" mount.

### Templated Policies

Vault supports a method of dynamic pathing, called [Templated Policies](https://www.vaultproject.io/docs/concepts/policies#templated-policies), that leverages attributes on Identity objects. This can be a powerful tool if you have well defined attributes assigned to the accounts and/or groups authenticating to Vault.

For instance, if you leverage [Vault's Identity secrets engine](https://www.vaultproject.io/docs/secrets/identity) and [pre-populate the entities with specific metadata](https://www.vaultproject.io/api-docs/secret/identity/entity#create-an-entity) such as a department, app, or team identifier. You could leverage the information to build a single policy the will be unique for every authenticating entity. HashiCorp's [Policy Templating](https://learn.hashicorp.com/tutorials/vault/policy-templating#available-templating-parameters) tutorial has good examples and details the attributes you can leverage.

> **Example**
>
> Suppose you have two entities, both with a metadata attribute called "app" and each entity has a unique value. You could construct a policy similar to the following:
>
> ```hcl
> # Allow listing root of secret mount
> path "secret/" {
>   capabilities = ["list"]
> }
> 
> # Allow listing of folder matching app name
> path "secret/{{ identity.entity.metadata.app }}/" {
>   capabilities = ["list"]
> }
>
> # Allow management of secrets within the folder matching the app name
> path "secret/{{ identity.entity.metadata.app }}/*" {
>   capabilities = ["create", "read", "update", "delete", "list"]
> }
> ```
>
> For an entity that logs into Vault that has an "app" attribute called "my_app", the effective policy would be:
>
> ```hcl
> # Allow listing root of secret mount
> path "secret/" {
>   capabilities = ["list"]
> }
>
> # Allow listing of folder matching app name
> path "secret/my_app/" {
>   capabilities = ["list"]
> }
>
> # Allow management of secrets within the folder matching the app name
> path "secret/my_app/*" {
>   capabilities = ["create", "read", "update", "delete", "list"]
> }
> ```

## Policy Design

Every environment is different and your policy design should reflect the needs of your organization. Consider how much automation you're willing to implement, how you want your users to leverage Vault (will they just be consuming secrets or will they be managing their own secret mounts, etc.?), how much time you can devote to managing and maintaining the service, and how much access you want your administrators to have.

### Adminstrator Policies

I tend to find that administrative access is often built overly broad up front, typically with a policy such as:

```hcl
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
```

While this will obviously work, this grants an excessive amount of permission to the administrators, in my opinion. Some things that I like to keep in mind when writing my own admin policies:

- Administrators should NOT be able to view or generate secrets they aren't explicitly authorized to
- Administrators should NOT be able to arbitrarily change critical system settings (e.g., audit config, auth mount settings, etc.)
- Administrators should be able to observe configured components (e.g., mounts, roles, audit devices, etc.)
- Administrators should be able to resolve common problems that users run into (e.g., resetting an AWS auth IAM role association, for instance)
- Administrators should be able to run commands to maintain the stability of the Vault environment (e.g., using the `sys/step-down` API endpoint to transfer the leader role to another node)

Being mindful of the activities your administrators will and should perform will help reduce the overall risk imposed by higher privileged accounts.

### KV Policies

In general the HashiCorp ACL policy examples are pretty transferable to any path within Vault (from `auth/*` to `sys/*` ). However, the basic examples don't get into the nuances of KVv2 pathing layout. KVv2, which happens to be the default secret engine mounted in a [dev](https://learn.hashicorp.com/tutorials/vault/getting-started-dev-server?in=vault/getting-started#starting-the-dev-server) instance of Vault, requires [special pathing](https://www.vaultproject.io/docs/secrets/kv/kv-v2#acl-rules) to work as expected.

Let's consider this basic KV policy to start:

```hcl
# Allow managing all secrets within mount
path "secret/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
```

This policy will allow full control over any KV secret within the `secret` mount whether it's KVv1 or KVv2.

However, suppose you want to be a bit more granular as you're sharing a single KV mount between two or more teams.

In KVv1 the policy would need to look something like this:

```hcl
# Allow listing of folders in mount root
path "secret/" {
  capabilities = ["list"]
}

# Allow managing all secrets within abc subfolder
path "secret/abc/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
```

To do the same thing in KVv2, it's more complicated:

```hcl
# Allow listing of folders in mount root
path "secret/metadata/" {
  capabilities = ["list"]
}

# Allow managing metadata within the abc subfolder
# Note: deleting metadata deletes the entire secret (non-recoverable)
path "secret/metadata/abc/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Allow reading and writing of secret content within the abc subfolder
# Note: 'delete' allows soft-deleting the latest secret version
path "secret/data/abc/*" {
  capabilities = ["create", "read", "update", "delete"]
}

# Allow soft-deleting of a specific secret version in the abc subfolder
path "secret/delete/abc/*" {
  capabilities = ["update"]
}

# Allow restoring of a specific soft-deleted secret version in the abc subfolder
path "secret/undelete/abc/*" {
  capabilities = ["update"]
}

# Allow permanently deleting of a specific secret version in the abc subfolder
path "secret/destroy/abc/*" {
  capabilities = ["update"]
}
```

[Templated Policies](#templated-policies) can be used along with this example to make management of your KVv2 policies simple while also providing very granular access.

### GUI Friendly Policies

Building policies to support the GUI takes some additional effort. Most of the examples used in this guide are GUI friendly. However, here are a few tips to help ensure the experience is adequate for your users:

- If you want to prevent access to secrets in specific sub-paths you'll need to grant list on each parent folder in the hierarchy individually to allow navigation.
- The URIs in the address bar are not the paths you need to put in your ACLs. Consult the [API guide](https://www.vaultproject.io/api-docs/index) for the required paths.
- The GUI may attempt to display more things than you realize. When viewing Database roles, for instance, both dynamic and static roles are displayed. Permission to list both [dynamic](https://www.vaultproject.io/api-docs/secret/databases#list-roles) and [static](https://www.vaultproject.io/api-docs/secret/databases#list-static-roles) roles may be required.
- If you're getting 403 Access Denied messages and can't figure out why, make sure you have an [Audit Device](https://www.vaultproject.io/docs/audit) configured and then review the logs for "permission denied" messages. The request path and operation, along with the policies attached to the in-use token, will be detailed in the record. If you're 100% sure your ACL rule covers the path and operation, make sure you don't have any conflicting rules (such as an explicit deny or more specific rule without the required permission). If there are no conflicts, try adding the `sudo` capability. I've found a couple instances where this is required but not documented (usually only needed in the `sys/` paths).

### Default Policy

The `default` policy, which is applied to all auth tokens by default, can be customized to your needs. Add or remove capabilities that should apply to any/all authenticated sessions within your Vault environment.

If you do not want the default policy applied to a particular auth method role then specify the `token_no_default_policy=true` attribute (e.g., on an [AppRole Role](https://www.vaultproject.io/api-docs/auth/approle#token_no_default_policy)) when you create your role.

## Policy Assignment

Policies can be assigned directly to a token or indirectly by assigning to an auth method role, an [Identity Entity](https://www.vaultproject.io/api-docs/secret/identity/entity), or an [Identity Group](https://www.vaultproject.io/api-docs/secret/identity/group). You'll have to determine which is the most appropriate method for your use case. However, I'll attepmt to summarize the differences of each method.

| Attribute/Type | Direct - Child | Direct - Role | Direct - Orphan | Role | Identity Entity | Identity Group |
| ----------------------------------------------- |------- | --- | ------ | ----- | ---- | ---- |
| Complexity to learn                             | Medium | Low | Medium | Low   | High | High |
| Can be assigned *any* policy by *requester*     | No*    | No  | Yes    | No    | No   | No   |
| Can be assigned any policy by admin             | No     | Yes | No     | Yes   | Yes  | Yes  |
| Able to leverage Templated Policies             | No     | No  | No     | Yes** | Yes  | Yes  |
| Flexible policy assignment through Terraform*** | No     | No  | No     | No    | Yes  | Yes  |

*: Can be assigned any policy the parent token is assigned.  
**: Requires an associated Identity object with relevant metadata defined.
***: Policies are assigned exclusively to roles through a single Terraform resource. Policies can be assigned non-exclusively to Identity Entities or Identity Groups via the `vault_identity_entity_policies` or `vault_identity_group_policies` resources with the `exclusive` flag set to `false`.

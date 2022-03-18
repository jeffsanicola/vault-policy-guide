# Vault ACL Policies

After struggling a bit with [ACL policies](https://www.vaultproject.io/docs/concepts/policies) early on in my experience with HashiCorp Vault and helping newcomers to Vault in the [community forums](https://discuss.hashicorp.com/c/vault/30), I decided to put together some practical policy examples for others to learn from. I'd recommend reading HashiCorp's official documentation as it has a lot of useful information.

This document reflects my own experiences and is not endorsed by HashiCorp in anyway. Use this information at your own risk.

## ACL Policy Overview

### What do ACL policies do?

Vault's Access Control List (ACL) policies specify a set of rules to apply to one or more paths. Policies, by themselves, do nothing. Policies are only meaningful when assigned to a token, entity, or group.

### Policy Construction

Policies are written in HashiCorp Configuration Language (HCL) files. Basic policies consist of three things:

* A name (must be lower-case)
* A path
* One or more "capabilities"

Paths must match valid folders or API endpoints to be effective.

Capabilities are a superset of CRUD operations:

* `create` - allows the creation of a resource that doesn't currently exist
* `read` - allows reading or listing of a particular resource or collection of resources
* `update` - allows the updating of an already existing resource
* `delete` - allows the removal of resource
* `list` - allows for listing the content of a folder
* `deny` - disallows access to the endpoint or folder - **avoid using this unless absolutely required**
* `sudo` - allows for elevating privilege for specific commands (only required in a small subset of endpoints)

Example

```hcl
# Allow reading and writing of any secret within the "secret" mount
path "secret/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
```

More advanced policies ([Fine-Grained Control Policies](https://www.vaultproject.io/docs/concepts/policies#fine-grained-control)) can control which attributes can be written to as well as some limited content enforcement. Note that these Fine-Grained policies may only be applied to key/value pair type attributes. Anything that accepts a "map" of data, such as KVv2 ironically enough, cannot be controlled using this method. Rather [Sentinel policies](https://www.vaultproject.io/docs/enterprise/sentinel), a Vault Enterprise feature, must be used to control content directly within Vault (or content enforcement can be built into your workflow, if feasible).

## Policy Pathing

### Folders vs. Endpoints

API endpoints that end with a `/` are considered a folder and only require the `read` or `list` capabilities.
Other endpoints will usually accept `create`, `read`, `update`, and `delete`. Some endpoints may require `sudo` for related commands to succeed, like the `sys/audit/*` endpoints. However, some endpoints only support a subset of these functions. Consult the API guide for specific capabilities applicable to the path in question.

When referencing the API guide you'll come across different REST methods: GET, POST, PUT, DELETE, and LIST. Their capability equivalents are as follows:

|REST Method|Capability|
|-----------|----------|
|GET        |read      |
|POST       |create, update|
|PUT        |create, update|
|DELETE     |delete    |
|LIST       |list      |

> Note: The LIST method is supported by select utilities, such as `curl`. Other utilities, such as PowerShell's Invoke-RestMethod only support the GET method. To list a folder where LIST isn't supported, use the GET method and append `?list=true` to the URI.

### Inheritance

Policy inheritance doesn't really exist in Vault. However, if you're like me  when I started out, you may have some bad assumptions derived from experience with other products.

Consider the following policy:

```hcl
path "secret/abc/*" {
  capabilities = ["read", "list"]
}

path "secret/abc/123/*" {
  capabilities = ["update"]
}
```

If you try to read `secret/abc/123/my_secret`, what will happen?
If you said you'll get a 403 Access Denied, you'd be right!

The `read` and `list` capabilities are overridden by the `update` capability on the more specific path.

Now what if you try to write to the same path?
If a secret already exists, the call will succeed. Otherwise a 403 will be returned.

Vault applies the most specific policy that matches the path. Policies do not accumulate as you traverse the folder structure.

If you want to be able to list folders in the `abc` folder but also write secrets in the `123` folder, then a policy like the following would be required:

```hcl
# Allow listing content in the secret mount.
path "secret/" {
  capabilities = ["read", "list"]
}

# Allow listing of secrets in the abc folder
path "secret/abc/" {
  capabilities = ["read", "list"]
}

# Allow reading and writing of secrets in the abc/123 folder
path "secret/abc/123/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
```

### Wildcards

The `*` character may look and behave like a traditional wildcard at first, however it's actually what's called a "glob" character and may only be used at the end of a path.

Valid - `secret/abc/*` - Allows access to any secret of folder within the `abc` folder

Valid - `secret/abc/1*` - Allows access to any secret or folder with a name beginning with `1` within the `abc` folder

Invalid - `secret/*/123` - The glob character is only allowed at the end of a path

Invalid - `secret/a*c` - The glob character is only allowed at the end of a path

There is another option that behaves a bit more like a traditional wildcard: the `+` character. The `+` character can substitute any full path component but not other partial parts of a path. The `+` character may also be used at the end of a path.

Valid - `secret/+/123` - Allows access to the `123` secret in any single parent folder (i.e., A secret `secret/abc/def/123` would not be allowed)

Valid - `secret/abc/+` - Allows access to any secret directly in the `abc` folder

Valid - `secret/+/*` - Allows access to any secret that exists in any subfolder of the secret mount.

Invalid - `secret/ab+/*` - The `+` character must be the only character between the `/`s

### Conflicting Policies

In general there are a few rules to keep in mind:

* The most specific policy will take priority
* If two policies are the same specificity then the resulting capabilities will be cumulative
* The `deny` capability takes priority over all other capabilities

Suppose you have multiple policies assigned to your token with different capabilities, what would happen?

Let's look at a few examples:

**Example 1**

```hcl
path "secret/abc/123/*" {
  capabilities = ["read"]
}
```

and

```hcl
path "secret/abc/123/*" {
  capabilities = ["update"]
}
```


If both of these policies are applied then the token is able to perform the cumulative actions provided in the policies - `read` and `update`, in this case.

**Example 2**

```hcl
path "secret/abc/123/*" {
  capabilities = ["read"]
}
```

and

```hcl
path "secret/abc/123/*" {
  capabilities = ["deny"]
}
```


In this case the `deny` capability takes priority over any other capability in this path and any interaction will result in a 403 error.

**Example 3**

```hcl
path "secret/abc/*" {
  capabilities = ["read"]
}
```

and

```hcl
path "+/abc/*" {
  capabilities = ["create", "read", "update", "delete"]
}
```


The `read` capability would win in this case as it is the most specific policy.

**Example 4**

```hcl
path "secret/+/*" {
  capabilities = ["read"]
}
```

and

```hcl
path "+/abc/*" {
  capabilities = ["create", "read", "update", "delete"]
}
```


The `read` capability would also win in this case as it is still the most specific policy. The `+` wildcard at the beginning of the second path makes it less specific as it can apply to any mount as opposed to only the "secret" mount.

### Templated Policies

Vault supports a method of dynamic pathing, called [Templated Policies](https://www.vaultproject.io/docs/concepts/policies#templated-policies), that leverages attributes on Identity objects. This can be a powerful tool if you have well defined attributes assigned to the accounts and/or groups authenticating to Vault.

For instance, if you leverage [Vault's Identity secrets engine](https://www.vaultproject.io/docs/secrets/identity) and [pre-populate the entities with specific metadata](https://www.vaultproject.io/api-docs/secret/identity/entity#create-an-entity) such as a department, app, or team identifier. You could leverage the information to build a single policy the will be unique for every authenticating entity.

Example

Suppose you have two entities, both with a metadata attribute called "app" and each entity has a unique value. You could construct a policy similar to the following:

```hcl
# Allow listing root of secret mount
path "secret/" {
  capabilities = ["read", "list"]
}

# Allow listing of folder matching app name
path "secret/{{ identity.entity.metadata.app }}/" {
  capabilities = ["read", "list"]
}

# Allow management of secrets within the folder matching the app name
path "secret/{{ identity.entity.metadata.app }}/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
```

For an entity that logs into Vault that has an app attribute called "my_app", the effective policy would be:

```hcl
# Allow listing root of secret mount
path "secret/" {
  capabilities = ["read", "list"]
}

# Allow listing of folder matching app name
path "secret/my_app/" {
  capabilities = ["read", "list"]
}

# Allow management of secrets within the folder matching the app name
path "secret/my_app/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
```

## Policy Design

Every environment is different and your policy design should reflect the needs of your organization. Consider how much automation you're willing to implement, how you want your users to leverage Vault (will they just be consuming secrets or will they be managing their own secret mounts, etc.?), how much time you can devote to managing and maintaining the service, and how much access you want your administrators to have.

I tend to find that administrative access is often built overly broad up front, typically with a policy such as:

```hcl
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
```

While this will obviously work, this grants an excessive amount of permission to the administrators, in my opinion. Some things that I like to keep in mind when writing my own admin policies:

* Administrators should NOT be able to view or generate secrets they aren't explicitly authorized to
* Administrators should NOT be able to arbitrarily change critical system settings (e.g., audit config, auth mount settings, etc.)
* Administrators should be able to observe configured components (e.g., mounts, roles, audit devices, etc.)
* Administrators should be able to resolve common problems that users run into (e.g., resetting an AWS auth IAM role association, for instance)
* Administrators should be able to run commands to maintain the stability of the Vault environment (e.g., using the `sys/step-down` API endpoint to transfer the leader role to another node)

Being mindful of the activities your administrators will and should perform will help reduce the overall risk imposed by higher privileged accounts.

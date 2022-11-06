# GUI Friendly Policies

This example demonstrates GUI friendly policies for KVv2 secrets in the `kvv2/` path.

The Terraform files create a user, KVv2 mount, and policy that grants access to secrets specific to the logged in user within the `kvv2/` path.

When creating a GUI friendly policy it's important to understand all the API calls occuring in the background. Leveraging built-in browers tools or the Audit Device logs will be helpful in understanding which endpoints are being called and via which REST methods.

## Example 9A

Users will only be able to read and write content to their respective folder within the example9/users subfolder.

1. Log in to Vault as `user9a` with password "changeme" via the GUI at <http://127.0.0.1:8200>
    "user9a" will be able to read/write within the "example9a/user9a" folder.
2. Click on `kvv2`
3. Notice you see a list of subfolders. If you click on any of them, other than `example9` you will receive an "access denied" message.
4. Click on `example9`
5. You will see two folders: `denied` and `users`. If you click on `denied` you will receive an "access denied" message.
6. Click on the `users` folder.
7. You will see two folders: `user9a` and `user9b`. Like the other folders, you'll only be able to open `user9a`.
8. Within the `user9a` folder you have full control of the content. Make any changes as desired.

## Example 9B

1. Log in to Vault as `user9b` with password "changeme" via the GUI at <http://127.0.0.1:8200>
    "user9b" will be able to read/write within the "example9a/user9b" folder.
2. Navigate to `kvv2` then `example9/users/`
3. If you attempt to open `user9a` you will receive an "access denied" message.
4. If you open `user9b` you will be able to fully interact with secrets in that directory.

## Observations

A few things to note with this example:

* Vault does not support "Access Based Enumeration" - you can either list contents of a folder or you cannot
* Any number of layers can be added. However, it's generally advised to keep the hierarchy as shallow as possible to reduce the need for recursive searches
* Similar restrictions can be applied to KVv1
* This example relies on Identity Entity names to be predefined so it's easy to identify the paths to use. Relying on auto-generated Identity Entities will make navigation more difficult.

## Setting up Access

Configure the `list` capability for each level of your hierarchy that needs to be traversed. When the desired path/depth is reached then you can specify paths that contain secret content with more capabilities.

Here's the rendered policy as used in this example.

```hcl
# allow listing root contents in KVv2
path "kvv2/metadata/" {
  capabilities = ["list"]
}

# allow listing contents in the example9/ folder
path "kvv2/metadata/example9/" {
  capabilities = ["list"]
}

# allow listing contents in the example9/users/ folder
path "kvv2/metadata/example9/users/" {
  capabilities = ["list"]
}

# allow KVv2 manage metadata in the example9/users/<username>/ folder
path "kvv2/metadata/example9/users/{{identity.entity.name}}/*" {
  capabilities = ["read", "update", "delete", "list", "patch"]
}

# allow KVv2 manage data
path "kvv2/data/example9/users/{{identity.entity.name}}/*" {
  capabilities = ["create", "read", "update", "delete", "patch"]
}

# allow KVv2 (soft)delete version
path "kvv2/delete/example9/users/{{identity.entity.name}}/*" {
  capabilities = ["update"]
}

# allow KVv2 undelete (restore version)
path "kvv2/undelete/example9/users/{{identity.entity.name}}/*" {
  capabilities = ["update"]
}

# allow KVv2 destroy (permanent delete version)
path "kvv2/destroy/example9/users/{{identity.entity.name}}/*" {
  capabilities = ["update"]
}
```

A KVv1 example would look like the following:

```hcl
# allow listing root contents in KVv2
path "kv/" {
  capabilities = ["list"]
}

# allow listing contents in the example9/ folder
path "kv/example9/" {
  capabilities = ["list"]
}

# allow listing contents in the example9/users/ folder
path "kv/example9/users/" {
  capabilities = ["list"]
}

# allow managing KV data
path "kv/example9/users/{{identity.entity.name}}/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
```

# Policies for user9
data "vault_policy_document" "users9" {
  # KVv2 policy
  rule {
    path         = "${vault_mount.kvv2.path}/metadata/"
    capabilities = ["list"]
    description  = "allow listing root contents in KVv2"
  }

  rule {
    path         = "${vault_mount.kvv2.path}/metadata/example9/"
    capabilities = ["list"]
    description  = "allow listing contents in the example9/ folder"
  }

  rule {
    path         = "${vault_mount.kvv2.path}/metadata/example9/users/"
    capabilities = ["list"]
    description  = "allow listing contents in the example9/users/ folder"
  }

  rule {
    path         = "${vault_mount.kvv2.path}/metadata/example9/users/{{identity.entity.name}}/*"
    capabilities = ["read", "update", "delete", "list", "patch"]
    description  = "allow KVv2 manage metadata in the example9/users/<username>/ folder"
  }

  rule {
    path         = "${vault_mount.kvv2.path}/data/example9/users/{{identity.entity.name}}/*"
    capabilities = ["create", "read", "update", "delete", "patch"]
    description  = "allow KVv2 manage data"
  }

  rule {
    path         = "${vault_mount.kvv2.path}/delete/example9/users/{{identity.entity.name}}/*"
    capabilities = ["update"]
    description  = "allow KVv2 (soft)delete version"
  }

  rule {
    path         = "${vault_mount.kvv2.path}/undelete/example9/users/{{identity.entity.name}}/*"
    capabilities = ["update"]
    description  = "allow KVv2 undelete (restore version)"
  }

  rule {
    path         = "${vault_mount.kvv2.path}/destroy/example9/users/{{identity.entity.name}}/*"
    capabilities = ["update"]
    description  = "allow KVv2 destroy (permanent delete version)"
  }
}

resource "vault_policy" "users9" {
  name   = "users9_policy"
  policy = data.vault_policy_document.users9.hcl
}

resource "vault_identity_entity_policies" "user9a" {
  policies = [
    vault_policy.users9.name
  ]

  exclusive = false

  entity_id = vault_identity_entity.users["9a"].id
}

resource "vault_identity_entity_policies" "user9b" {
  policies = [
    vault_policy.users9.name
  ]

  exclusive = false

  entity_id = vault_identity_entity.users["9b"].id
}

resource "vault_kv_secret_v2" "users9" {
  for_each = toset(["user9a", "user9b"])
  mount    = vault_mount.kvv2.path
  name     = "example9/users/${each.key}/my_secret"

  data_json = jsonencode({
    "password" = "P@ssw0rd"
  })
}

resource "vault_kv_secret_v2" "access_denied" {
  for_each = toset(["user9a", "user9b"])
  mount    = vault_mount.kvv2.path
  name     = "example9/denied/secret"

  data_json = jsonencode({
    "password" = "P@ssw0rd"
  })
}

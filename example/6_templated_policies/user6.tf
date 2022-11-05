data "vault_policy_document" "user6" {
  # KVv2 policy
  rule {
    path         = "${vault_mount.kvv2.path}/metadata/"
    capabilities = ["read", "list"]
    description  = "allow list on kv"
  }

  rule {
    path         = "${vault_mount.kvv2.path}/metadata/{{identity.entity.name}}/*"
    capabilities = ["read", "update", "delete", "list", "patch"]
    description  = "allow managing metadata"
  }

  rule {
    path         = "${vault_mount.kvv2.path}/data/{{identity.entity.name}}/*"
    capabilities = ["create", "read", "update", "delete", "patch"]
    description  = "allow full control on kv/{{identity.entity.name}}"
  }

  rule {
    path         = "${vault_mount.kvv2.path}/delete/{{identity.entity.name}}/*"
    capabilities = ["update"]
    description  = "allow delete on kv/{{identity.entity.name}}"
  }

  rule {
    path         = "${vault_mount.kvv2.path}/undelete/{{identity.entity.name}}/*"
    capabilities = ["update"]
    description  = "allow undelete on kv/{{identity.entity.name}}"
  }

  rule {
    path         = "${vault_mount.kvv2.path}/destroy/{{identity.entity.name}}/*"
    capabilities = ["update"]
    description  = "allow destroy on kv/{{identity.entity.name}}"
  }
}

resource "vault_policy" "user6" {
  name   = "user6_policy"
  policy = data.vault_policy_document.user6.hcl
}

resource "vault_generic_endpoint" "user6" {
  depends_on = [vault_auth_backend.userpass]
  for_each   = toset(var.users)

  path                 = "auth/${vault_auth_backend.userpass.path}/users/${each.key}"
  ignore_absent_fields = true

  data_json = jsonencode({
    "policies" = ["${vault_policy.user6.name}"],
    "password" = "changeme"
  })
}

resource "vault_identity_entity" "user6" {
  # Need to create an Identity Entity so that the name is not randomly generated at first login
  for_each = vault_generic_endpoint.user6
  name     = each.key
}

resource "vault_identity_entity_alias" "user6" {
  # Tie the Identity Entity to the userpass user
  for_each       = vault_identity_entity.user6
  name           = each.key
  mount_accessor = vault_auth_backend.userpass.accessor
  canonical_id   = each.value.id
}

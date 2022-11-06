resource "vault_mount" "kvv1" {
  path = "kv"
  type = "kv"
}

resource "vault_mount" "kvv2" {
  path    = "kvv2"
  type    = "kv"
  options = { version = "2" }
}

resource "vault_auth_backend" "userpass" {
  type = "userpass"
}

resource "vault_generic_endpoint" "users" {
  depends_on = [vault_auth_backend.userpass]
  for_each   = toset(var.users)

  path                 = "auth/${vault_auth_backend.userpass.path}/users/user${each.key}"
  ignore_absent_fields = true

  data_json = jsonencode({
    "password" = "changeme"
  })
}

resource "vault_identity_entity" "users" {
  # Need to create an Identity Entity so that the name is not randomly generated at first login
  for_each          = vault_generic_endpoint.users
  name              = each.key
  external_policies = true
}

resource "vault_identity_entity_policies" "users" {
  for_each = vault_identity_entity.users
  policies = [
    "user${each.key}_policy"
  ]
  exclusive = false
  entity_id = each.value.id
}

resource "vault_identity_entity_alias" "users" {
  # Tie the Identity Entity to the userpass user
  for_each       = vault_identity_entity.users
  name           = each.key
  mount_accessor = vault_auth_backend.userpass.accessor
  canonical_id   = each.value.id
}

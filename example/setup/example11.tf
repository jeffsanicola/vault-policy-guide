# Policies for user11
data "vault_policy_document" "user11" {
  # KVv2 policy
  rule {
    path         = "${vault_mount.kvv2.path}/metadata"
    capabilities = ["list"]
    description  = "allow KVv2 managing all metadata and permanently deleting secret"
  }
}

resource "vault_policy" "user11" {
  name   = "user11_policy"
  policy = data.vault_policy_document.user11.hcl
}

# User account
resource "vault_generic_endpoint" "user11" {
  depends_on = [vault_auth_backend.userpass]

  path                 = "auth/${vault_auth_backend.userpass.path}/users/user11"
  ignore_absent_fields = true

  data_json = jsonencode({
    "password" = var.default_password
    "policies" = "user11_policy"
  })
}

# Policy for user11's entity ID
data "vault_policy_document" "entity11" {
  # KVv2 policy
  rule {
    path         = "${vault_mount.kvv2.path}/metadata"
    capabilities = ["list"]
    description  = "allow KVv2 managing all metadata and permanently deleting secret"
  }
}

resource "vault_policy" "entity11" {
  name   = "entity11_policy"
  policy = data.vault_policy_document.entity11.hcl
}

# Identity Entity
resource "vault_identity_entity" "user11" {
  name              = "user11"
  external_policies = true
}

resource "vault_identity_entity_policies" "user11" {
  policies = [
    vault_policy.entity11.name
  ]
  exclusive = false
  entity_id = vault_identity_entity.user11.id
}

resource "vault_identity_entity_alias" "user11" {
  name           = vault_identity_entity.user11.name
  mount_accessor = vault_auth_backend.userpass.accessor
  canonical_id   = vault_identity_entity.user11.id
}

# Policy for group11
data "vault_policy_document" "group11" {
  # KVv2 policy
  rule {
    path         = "${vault_mount.kvv2.path}/metadata"
    capabilities = ["list"]
    description  = "allow KVv2 managing all metadata and permanently deleting secret"
  }
}

resource "vault_policy" "group11" {
  name   = "group11_policy"
  policy = data.vault_policy_document.group11.hcl
}

# Identity Group
resource "vault_identity_group" "group11" {
  name     = "example11"
  type     = "internal"
  policies = [vault_policy.group11.name]

  member_entity_ids = [vault_identity_entity.user11.id]
}

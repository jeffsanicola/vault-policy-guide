# Policies for user9
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

resource "vault_identity_group" "example11_devops" {
  name     = "example11_devops"
  type     = "internal"
  policies = [vault_policy.group11.name]

  metadata = {
    version = "2"
  }
}

resource "vault_generic_endpoint" "user11" {
  depends_on = [vault_auth_backend.userpass]

  path                 = "auth/${vault_auth_backend.userpass.path}/users/user11"
  ignore_absent_fields = true

  data_json = jsonencode({
    "password" = "changeme"
  })
}

resource "vault_identity_entity" "user11" {
  # Need to create an Identity Entity so that the name is not randomly generated at first login
  name              = "user11"
  external_policies = true
}

resource "vault_identity_entity_policies" "user11" {
  policies = [
    vault_policy.user11.name
  ]
  exclusive = false
  entity_id = vault_identity_entity.user11.id
}

resource "vault_identity_entity_alias" "user11" {
  # Tie the Identity Entity to the userpass user
  name           = vault_identity_entity.user11.name
  mount_accessor = vault_auth_backend.userpass.accessor
  canonical_id   = vault_identity_entity.user11.id
}

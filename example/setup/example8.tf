# Policies for user8
data "vault_policy_document" "user8" {
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
    description  = "allow full control on kvv2/{{identity.entity.name}}"
  }

  rule {
    path         = "${vault_mount.kvv2.path}/delete/{{identity.entity.name}}/*"
    capabilities = ["update"]
    description  = "allow delete on kvv2/{{identity.entity.name}}"
  }

  rule {
    path         = "${vault_mount.kvv2.path}/undelete/{{identity.entity.name}}/*"
    capabilities = ["update"]
    description  = "allow undelete on kvv2/{{identity.entity.name}}"
  }

  rule {
    path         = "${vault_mount.kvv2.path}/destroy/{{identity.entity.name}}/*"
    capabilities = ["update"]
    description  = "allow destroy on kvv2/{{identity.entity.name}}"
  }
}

resource "vault_policy" "user8" {
  name   = "user8_policy"
  policy = data.vault_policy_document.user8.hcl
}

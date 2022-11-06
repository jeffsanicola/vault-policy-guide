# Policies for user6
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

data "vault_policy_document" "user1_policy" {
  rule {
    path         = "${vault_mount.kvv1.path}/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow all on kv"
  }
}

resource "vault_policy" "user1_policy" {
  name   = "user1_policy"
  policy = data.vault_policy_document.user1_policy.hcl
}

data "vault_policy_document" "example" {
  rule {
    path         = "${vault_mount.kvv1.path}/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow all on kv"
  }
}

resource "vault_policy" "example" {
  name   = "example_policy"
  policy = data.vault_policy_document.example.hcl
}

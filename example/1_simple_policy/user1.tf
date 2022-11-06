data "vault_policy_document" "example" {
  rule {
    path         = "${vault_mount.kv.path}/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow all on kv"
  }
}

resource "vault_policy" "example" {
  name   = "example_policy"
  policy = data.vault_policy_document.example.hcl
}

resource "vault_generic_endpoint" "user1" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/${vault_auth_backend.userpass.path}/users/user1"
  ignore_absent_fields = true

  data_json = jsonencode({
    "policies" = ["${vault_policy.example.name}"],
    "password" = "changeme"
  })
}

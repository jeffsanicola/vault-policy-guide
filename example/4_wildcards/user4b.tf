data "vault_policy_document" "user4b" {
  rule {
    path         = "${vault_mount.kv.path}/"
    capabilities = ["list"]
    description  = "allow list on kv"
  }

  rule {
    path         = "${vault_mount.kv.path}/+/my_secret"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow creating \"my_secret\" in any folder within the KV root path"
  }
}

resource "vault_policy" "user4b" {
  name   = "user4b_policy"
  policy = data.vault_policy_document.user4b.hcl
}

resource "vault_generic_endpoint" "user4b" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/${vault_auth_backend.userpass.path}/users/user4b"
  ignore_absent_fields = true

  data_json = jsonencode({
    "policies" = ["${vault_policy.user4b.name}"],
    "password" = "changeme"
  })
}

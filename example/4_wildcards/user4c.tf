data "vault_policy_document" "user4c" {
  rule {
    path         = "${vault_mount.kv.path}/"
    capabilities = ["list"]
    description  = "allow list on kv"
  }

  rule {
    path         = "${vault_mount.kv.path}/+/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow creating secrets in subfolders only (no secrets in root of mount)"
  }
}

resource "vault_policy" "user4c" {
  name   = "user4c_policy"
  policy = data.vault_policy_document.user4c.hcl
}

resource "vault_generic_endpoint" "user4c" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/${vault_auth_backend.userpass.path}/users/user4c"
  ignore_absent_fields = true

  data_json = jsonencode({
    "policies" = ["${vault_policy.user4c.name}"],
    "password" = "changeme"
  })
}

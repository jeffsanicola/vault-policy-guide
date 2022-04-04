data "vault_policy_document" "secret" {
  rule {
    path         = "${vault_mount.kv.path}/"
    capabilities = ["list"]
    description  = "List my_secrets"
  }

  rule {
    path         = "${vault_mount.kv.path}/my_secrets"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow all on kv"
  }
}

resource "vault_policy" "secret" {
  name   = "secret_policy"
  policy = data.vault_policy_document.secret.hcl
}

resource "vault_generic_endpoint" "user2a" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/${vault_auth_backend.userpass.path}/users/user2a"
  ignore_absent_fields = true

  data_json = jsonencode({
    "policies" = ["${vault_policy.secret.name}"],
    "password" = "changeme"
  })
}

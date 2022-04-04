data "vault_policy_document" "folder" {
  rule {
    path         = "${vault_mount.kv.path}/"
    capabilities = ["list"]
    description  = "List my_secrets"
  }


  rule {
    path         = "${vault_mount.kv.path}/my_secrets/"
    capabilities = ["list"]
    description  = "List my_secrets"
  }

  rule {
    path         = "${vault_mount.kv.path}/my_secrets/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow all on kv/my_secrets"
  }
}

resource "vault_policy" "folder" {
  name   = "folder_policy"
  policy = data.vault_policy_document.folder.hcl
}


resource "vault_generic_endpoint" "user2b" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/${vault_auth_backend.userpass.path}/users/user2b"
  ignore_absent_fields = true

  data_json = jsonencode({
    "policies" = ["${vault_policy.folder.name}"],
    "password" = "changeme"
  })
}

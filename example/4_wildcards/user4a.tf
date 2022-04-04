data "vault_policy_document" "user4a" {
  rule {
    path         = "${vault_mount.kv.path}/"
    capabilities = ["list"]
    description  = "allow list on kv"
  }

  rule {
    path         = "${vault_mount.kv.path}/folder1/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow all on kv/folder1"
  }

  rule {
    path         = "${vault_mount.kv.path}/folder2/p*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow all on kv/folder2 when secret name begins with \"p\""
  }

  rule {
    path         = "${vault_mount.kv.path}/folder3/+"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow creating secrets in folder3 only"
  }

  rule {
    path         = "+/folder4/my_secret"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow creating secret \"my_secret\" only in folder4 within any compatible KV mount"
  }
}

resource "vault_policy" "user4a" {
  name   = "user4a_policy"
  policy = data.vault_policy_document.user4a.hcl
}

resource "vault_generic_endpoint" "user4a" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/${vault_auth_backend.userpass.path}/users/user4a"
  ignore_absent_fields = true

  data_json = jsonencode({
    "policies" = ["${vault_policy.user4a.name}"],
    "password" = "changeme"
  })
}

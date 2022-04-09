data "vault_policy_document" "user5d_1" {
  rule {
    path         = "${vault_mount.kv.path}/*"
    capabilities = ["list"]
    description  = "allow list on kv"
  }

  rule {
    path         = "${vault_mount.kv.path}/+/*"
    capabilities = ["read"]
    description  = "allow read in any subfolder of kv/"
  }
}

data "vault_policy_document" "user5d_2" {
  rule {
    path         = "+/*"
    capabilities = ["list"]
    description  = "allow list on kv"
  }

  rule {
    path         = "+/folder1/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow all on kv/folder1"
  }
}

resource "vault_policy" "user5d_1" {
  name   = "user5d_1_policy"
  policy = data.vault_policy_document.user5d_1.hcl
}

resource "vault_policy" "user5d_2" {
  name   = "user5d_2_policy"
  policy = data.vault_policy_document.user5d_2.hcl
}

resource "vault_generic_endpoint" "user5d" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/${vault_auth_backend.userpass.path}/users/user5d"
  ignore_absent_fields = true

  data_json = jsonencode({
    "policies" = ["${vault_policy.user5d_1.name}", "${vault_policy.user5d_2.name}"],
    "password" = "changeme"
  })
}

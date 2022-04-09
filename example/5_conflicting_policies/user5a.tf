data "vault_policy_document" "user5a_1" {
  rule {
    path         = "${vault_mount.kv.path}/*"
    capabilities = ["list"]
    description  = "allow list on kv"
  }

  rule {
    path         = "${vault_mount.kv.path}/folder1/*"
    capabilities = ["read", "list"]
    description  = "allow read on kv/folder1"
  }
}

data "vault_policy_document" "user5a_2" {
  rule {
    path         = "${vault_mount.kv.path}/*"
    capabilities = ["list"]
    description  = "allow list on kv"
  }

  rule {
    path         = "${vault_mount.kv.path}/folder1/*"
    capabilities = ["update", "list"]
    description  = "allow update on kv/folder1"
  }
}

resource "vault_policy" "user5a_1" {
  name   = "user5a_1_policy"
  policy = data.vault_policy_document.user5a_1.hcl
}

resource "vault_policy" "user5a_2" {
  name   = "user5a_2_policy"
  policy = data.vault_policy_document.user5a_2.hcl
}

resource "vault_generic_endpoint" "user5a" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/${vault_auth_backend.userpass.path}/users/user5a"
  ignore_absent_fields = true

  data_json = jsonencode({
    "policies" = ["${vault_policy.user5a_1.name}", "${vault_policy.user5a_2.name}"],
    "password" = "changeme"
  })
}

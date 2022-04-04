resource "vault_mount" "kv" {
  path = "kv"
  type = "kv"
}

data "vault_policy_document" "example" {
  rule {
    path         = "${vault_mount.kv.path}/"
    capabilities = ["list"]
    description  = "Allow listing of KV mount"
  }

  rule {
    path         = "${vault_mount.kv.path}/example/*"
    capabilities = ["read", "list"]
    description  = "allow reading/listing in the example folder"
  }

  rule {
    path         = "${vault_mount.kv.path}/example/subfolder/*"
    capabilities = ["update"]
    description  = "allow updating in the example folder"
  }
}

resource "vault_generic_secret" "secret" {
  path      = "${vault_mount.kv.path}/example/test_secret"
  data_json = jsonencode({ "password" = "test" })
}

resource "vault_generic_secret" "subfolder_secret" {
  path      = "${vault_mount.kv.path}/example/subfolder/test_secret"
  data_json = jsonencode({ "password" = "test" })
}

resource "vault_policy" "example" {
  name   = "example_policy"
  policy = data.vault_policy_document.example.hcl
}

resource "vault_auth_backend" "userpass" {
  type = "userpass"
}

resource "vault_generic_endpoint" "user3" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/${vault_auth_backend.userpass.path}/users/user3"
  ignore_absent_fields = true

  data_json = jsonencode({
    "policies" = ["${vault_policy.example.name}"],
    "password" = "changeme"
  })
}

resource "vault_mount" "kv" {
  path = "kv"
  type = "kv"
}

resource "vault_mount" "kv-test" {
  path = "kv-test"
  type = "kv"
}

resource "vault_auth_backend" "userpass" {
  type = "userpass"
}

resource "vault_generic_secret" "example" {
  path = "${vault_mount.kv.path}/folder1/my_secret"
  data_json = jsonencode({
    "password" = "changeme"
  })
}

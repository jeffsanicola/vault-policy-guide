resource "vault_mount" "kv" {
  path = "kv"
  type = "kv"
}

resource "vault_auth_backend" "userpass" {
  type = "userpass"
}

resource "random_password" "secret" {
  length = 16
}

resource "vault_generic_secret" "secret" {
  path      = "${vault_mount.kv.path}/example/test_secret"
  data_json = jsonencode({ "password" = random_password.secret.result })
}

resource "random_password" "subfolder_secret" {
  length = 16
}

resource "vault_generic_secret" "subfolder_secret" {
  path      = "${vault_mount.kv.path}/example/subfolder/test_secret"
  data_json = jsonencode({ "password" = random_password.subfolder_secret.result })
}

resource "vault_mount" "kv" {
  path    = "kv"
  type    = "kv"
  options = { version = "2" }
}

resource "vault_auth_backend" "userpass" {
  type = "userpass"
}

resource "random_password" "example" {
  length = 16
}

resource "vault_kv_secret_v2" "example" {
  mount = vault_mount.kv.path
  name  = "my_secret"

  data_json = jsonencode({
    "password" = random_password.example.result
  })
}

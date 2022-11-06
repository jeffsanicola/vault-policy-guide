resource "vault_mount" "kv" {
  path    = "kv"
  type    = "kv"
  options = { version = "2" }
}

resource "vault_auth_backend" "userpass" {
  type = "userpass"
}

resource "random_password" "example" {
  for_each = toset(var.users)

  length = 16
}

resource "vault_kv_secret_v2" "example" {
  for_each = random_password.example
  mount    = vault_mount.kv.path
  name     = "${each.key}/my_secret"

  data_json = jsonencode({
    "password" = each.value.result
  })
}

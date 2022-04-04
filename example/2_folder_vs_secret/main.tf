resource "vault_mount" "kv" {
  path = "kv"
  type = "kv"
}

resource "vault_auth_backend" "userpass" {
  type = "userpass"
}

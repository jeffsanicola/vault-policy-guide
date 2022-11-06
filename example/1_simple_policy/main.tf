resource "vault_mount" "kv" {
  path = "kv"
  type = "kv-v2"
}

resource "vault_auth_backend" "userpass" {
  type = "userpass"
}

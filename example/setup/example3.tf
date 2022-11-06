data "vault_policy_document" "user3" {
  rule {
    path         = "${vault_mount.kvv1.path}/"
    capabilities = ["list"]
    description  = "Allow listing of KV mount"
  }

  rule {
    path         = "${vault_mount.kvv1.path}/example/*"
    capabilities = ["read", "list"]
    description  = "allow reading/listing in the example folder"
  }

  rule {
    path         = "${vault_mount.kvv1.path}/example/subfolder/*"
    capabilities = ["update"]
    description  = "allow updating in the example folder"
  }
}

resource "vault_policy" "user3" {
  name   = "user3_policy"
  policy = data.vault_policy_document.user3.hcl
}

resource "random_password" "example3_secret" {
  length = 16
}

resource "vault_generic_secret" "example3" {
  path = "${vault_mount.kvv1.path}/example3/secret"
  data_json = jsonencode({
    "password" = random_password.example3_secret.result
  })
}

resource "random_password" "example3_subfolder_secret" {
  length = 16
}

resource "vault_generic_secret" "example3_subfolder_secret" {
  path = "${vault_mount.kvv1.path}/example3/subfolder/secret"
  data_json = jsonencode({
    "password" = random_password.example3_subfolder_secret.result
  })
}

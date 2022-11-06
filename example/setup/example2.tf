# Policies for user2a
data "vault_policy_document" "user2a" {
  rule {
    path         = "${vault_mount.kvv1.path}/"
    capabilities = ["list"]
    description  = "List my_secrets"
  }

  rule {
    path         = "${vault_mount.kvv1.path}/my_secrets"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow all on kv"
  }
}

resource "vault_policy" "user2a" {
  name   = "user2a_policy"
  policy = data.vault_policy_document.user2a.hcl
}

data "vault_policy_document" "user2b" {
  rule {
    path         = "${vault_mount.kvv1.path}/"
    capabilities = ["list"]
    description  = "List my_secrets"
  }


  rule {
    path         = "${vault_mount.kvv1.path}/my_secrets/"
    capabilities = ["list"]
    description  = "List my_secrets"
  }

  rule {
    path         = "${vault_mount.kvv1.path}/my_secrets/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow all on kv/my_secrets"
  }
}

resource "vault_policy" "user2b" {
  name   = "user2b_policy"
  policy = data.vault_policy_document.user2b.hcl
}

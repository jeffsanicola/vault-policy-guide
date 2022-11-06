# Policies for user4a
data "vault_policy_document" "user4a" {
  rule {
    path         = "${vault_mount.kvv1.path}/"
    capabilities = ["list"]
    description  = "allow list on kv"
  }

  rule {
    path         = "${vault_mount.kvv1.path}/folder1/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow all on kv/folder1"
  }

  rule {
    path         = "${vault_mount.kvv1.path}/folder2/p*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow all on kv/folder2 when secret name begins with \"p\""
  }

  rule {
    path         = "${vault_mount.kvv1.path}/folder3/+"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow creating secrets in folder3 only"
  }

  rule {
    path         = "+/folder4/my_secret"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow creating secret \"my_secret\" only in folder4 within any compatible KV mount"
  }
}

resource "vault_policy" "user4a" {
  name   = "user4a_policy"
  policy = data.vault_policy_document.user4a.hcl
}

# Policies for user4b
data "vault_policy_document" "user4b" {
  rule {
    path         = "${vault_mount.kvv1.path}/"
    capabilities = ["list"]
    description  = "allow list on kv"
  }

  rule {
    path         = "${vault_mount.kvv1.path}/+/my_secret"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow creating \"my_secret\" in any folder within the KV root path"
  }
}

resource "vault_policy" "user4b" {
  name   = "user4b_policy"
  policy = data.vault_policy_document.user4b.hcl
}

# Policies for user4c
data "vault_policy_document" "user4c" {
  rule {
    path         = "${vault_mount.kvv1.path}/"
    capabilities = ["list"]
    description  = "allow list on kv"
  }

  rule {
    path         = "${vault_mount.kvv1.path}/+/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow creating secrets in subfolders only (no secrets in root of mount)"
  }
}

resource "vault_policy" "user4c" {
  name   = "user4c_policy"
  policy = data.vault_policy_document.user4c.hcl
}

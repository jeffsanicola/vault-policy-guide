# Policies for user8a
data "vault_policy_document" "user8a" {
  # KVv1 policy
  rule {
    path         = "${vault_mount.kvv1.path}/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow full KVv1 access"
  }
}

resource "vault_policy" "user8a" {
  name   = "user8a_policy"
  policy = data.vault_policy_document.user8a.hcl
}

# Policies for user8b
data "vault_policy_document" "user8b" {
  # KVv1 policy
  rule {
    path         = "${vault_mount.kvv1.path}/*"
    capabilities = ["read", "list"]
    description  = "allow read-only KVv1 access"
  }
}

resource "vault_policy" "user8b" {
  name   = "user8b_policy"
  policy = data.vault_policy_document.user8b.hcl
}

# Policies for user8c
data "vault_policy_document" "user8c" {
  # KVv2 policy
  rule {
    path         = "${vault_mount.kvv2.path}/metadata/*"
    capabilities = ["read", "update", "delete", "list", "patch"]
    description  = "allow KVv2 managing all metadata and permanently deleting secret"
  }

  rule {
    path         = "${vault_mount.kvv2.path}/data/*"
    capabilities = ["create", "read", "update", "delete", "patch"]
    description  = "allow KVv2 managing data"
  }

  rule {
    path         = "${vault_mount.kvv2.path}/delete/*"
    capabilities = ["update"]
    description  = "allow KVv2 (soft)delete version"
  }

  rule {
    path         = "${vault_mount.kvv2.path}/undelete/*"
    capabilities = ["update"]
    description  = "allow KVv2 undelete (restore version)"
  }

  rule {
    path         = "${vault_mount.kvv2.path}/destroy/*"
    capabilities = ["update"]
    description  = "allow KVv2 destroy (permanent delete version)"
  }
}

resource "vault_policy" "user8c" {
  name   = "user8c_policy"
  policy = data.vault_policy_document.user8c.hcl
}

# Policies for user8d
data "vault_policy_document" "user8d" {
  # KVv2 policy
  rule {
    path         = "${vault_mount.kvv2.path}/metadata/*"
    capabilities = ["read", "list"]
    description  = "allow KVv2 reading all metadata"
  }

  rule {
    path         = "${vault_mount.kvv2.path}/data/*"
    capabilities = ["read"]
    description  = "allow KVv2 reading data"
  }
}

resource "vault_policy" "user8d" {
  name   = "user8d_policy"
  policy = data.vault_policy_document.user8d.hcl
}

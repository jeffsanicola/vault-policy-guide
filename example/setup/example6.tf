# Policies for user6a
data "vault_policy_document" "user6a" {
  # KVv1 policy
  rule {
    path         = "${vault_mount.kvv1.path}/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow full KVv1 access"
  }
}

resource "vault_policy" "user6a" {
  name   = "user6a_policy"
  policy = data.vault_policy_document.user6a.hcl
}

# Policies for user6b
data "vault_policy_document" "user6b" {
  # KVv1 policy
  rule {
    path         = "${vault_mount.kvv1.path}/*"
    capabilities = ["read", "list"]
    description  = "allow read-only KVv1 access"
  }
}

resource "vault_policy" "user6b" {
  name   = "user6b_policy"
  policy = data.vault_policy_document.user6b.hcl
}

# Policies for user6c
data "vault_policy_document" "user6c" {
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

resource "vault_policy" "user6c" {
  name   = "user6c_policy"
  policy = data.vault_policy_document.user6c.hcl
}

# Policies for user6d
data "vault_policy_document" "user6d" {
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

resource "vault_policy" "user6d" {
  name   = "user6d_policy"
  policy = data.vault_policy_document.user6d.hcl
}

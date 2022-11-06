# Policies for user5a
data "vault_policy_document" "user5a" {
  rule {
    path         = "${vault_mount.kvv1.path}/*"
    capabilities = ["list"]
    description  = "allow list on kv"
  }

  rule {
    path         = "${vault_mount.kvv1.path}/folder1/*"
    capabilities = ["read", "list"]
    description  = "allow read on kv/folder1"
  }
}

resource "vault_policy" "user5a_1" {
  name   = "user5a_policy"
  policy = data.vault_policy_document.user5a.hcl
}

data "vault_policy_document" "user5a_addon" {
  rule {
    path         = "${vault_mount.kvv1.path}/*"
    capabilities = ["list"]
    description  = "allow list on kv"
  }

  rule {
    path         = "${vault_mount.kvv1.path}/folder1/*"
    capabilities = ["update", "list"]
    description  = "allow update on kv/folder1"
  }
}

resource "vault_policy" "user5a_addon" {
  name   = "user5a_addon_policy"
  policy = data.vault_policy_document.user5a_addon.hcl
}

resource "vault_identity_entity_policies" "user5a_addon" {
  policies = [
    vault_policy.user5a_addon.name
  ]
  exclusive = false
  entity_id = vault_identity_entity.users["5a"].id
}

# Policies for user5b
data "vault_policy_document" "user5b" {
  rule {
    path         = "${vault_mount.kvv1.path}/*"
    capabilities = ["list"]
    description  = "allow list on kv"
  }

  rule {
    path         = "${vault_mount.kvv1.path}/folder1/*"
    capabilities = ["read"]
    description  = "allow read on kv/folder1"
  }
}

resource "vault_policy" "user5b" {
  name   = "user5b_policy"
  policy = data.vault_policy_document.user5b.hcl
}

data "vault_policy_document" "user5b_addon" {
  rule {
    path         = "${vault_mount.kvv1.path}/*"
    capabilities = ["list"]
    description  = "allow list on kv"
  }

  rule {
    path         = "${vault_mount.kvv1.path}/folder1/*"
    capabilities = ["deny"]
    description  = "allow deny on kv/folder1"
  }
}

resource "vault_policy" "user5b_addon" {
  name   = "user5b_addon_policy"
  policy = data.vault_policy_document.user5b_addon.hcl
}

resource "vault_identity_entity_policies" "user5b_addon" {
  policies = [
    vault_policy.user5b_addon.name
  ]
  exclusive = false
  entity_id = vault_identity_entity.users["5b"].id
}

# Policies for user5c
data "vault_policy_document" "user5c" {
  rule {
    path         = "${vault_mount.kvv1.path}/*"
    capabilities = ["list"]
    description  = "allow list on kv"
  }

  rule {
    path         = "${vault_mount.kvv1.path}/folder1/*"
    capabilities = ["read"]
    description  = "allow read on kv/folder1"
  }
}

resource "vault_policy" "user5c" {
  name   = "user5c_policy"
  policy = data.vault_policy_document.user5c.hcl
}

data "vault_policy_document" "user5c_addon" {
  rule {
    path         = "+/*"
    capabilities = ["list"]
    description  = "allow list on kv"
  }

  rule {
    path         = "+/folder1/*"
    capabilities = ["create", "read", "update", "delete"]
    description  = "allow all on kv/folder1"
  }
}

resource "vault_policy" "user5c_addon" {
  name   = "user5c_addon_policy"
  policy = data.vault_policy_document.user5c_addon.hcl
}

resource "vault_identity_entity_policies" "user5c_addon" {
  policies = [
    vault_policy.user5c_addon.name
  ]
  exclusive = false
  entity_id = vault_identity_entity.users["5c"].id
}

# Policies for user5d
data "vault_policy_document" "user5d" {
  rule {
    path         = "${vault_mount.kvv1.path}/*"
    capabilities = ["list"]
    description  = "allow list on kv"
  }

  rule {
    path         = "${vault_mount.kvv1.path}/+/*"
    capabilities = ["read"]
    description  = "allow read in any subfolder of kv/"
  }
}

resource "vault_policy" "user5d" {
  name   = "user5d_policy"
  policy = data.vault_policy_document.user5d.hcl
}

data "vault_policy_document" "user5d_addon" {
  rule {
    path         = "+/*"
    capabilities = ["list"]
    description  = "allow list on kv"
  }

  rule {
    path         = "+/example5/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow all on kv/example5"
  }
}

resource "vault_policy" "user5d_addon" {
  name   = "user5d_addon_policy"
  policy = data.vault_policy_document.user5d_addon.hcl
}

resource "vault_identity_entity_policies" "user5d_addon" {
  policies = [
    vault_policy.user5d_addon.name
  ]
  exclusive = false
  entity_id = vault_identity_entity.users["5d"].id
}

resource "random_password" "example5" {
  length = 16
}

resource "vault_generic_secret" "example5" {
  path = "${vault_mount.kvv1.path}/example5/my_secret"
  data_json = jsonencode({
    "password" = random_password.example5.result
  })
}

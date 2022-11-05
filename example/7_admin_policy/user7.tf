data "vault_policy_document" "user7" {
  # Admin policy
  rule {
    path         = "${vault_mount.kv.path}/metadata/"
    capabilities = ["read", "list"]
    description  = "allow list on kv"
  }

  rule {
    path         = "${vault_mount.kv.path}/metadata/*"
    capabilities = ["read", "list"]
    description  = "allow listing secrets and metadata"
  }

  rule {
    path         = "${vault_mount.kv.path}/subkeys/*"
    capabilities = ["read"]
    description  = "allow reading of subkeys"
  }

  rule {
    path         = "auth/+/config/*"
    capabilities = ["read", "update", "delete", "list"]
    description  = "Allow managing Auth method configurations"
  }

  rule {
    path         = "auth/+/role"
    capabilities = ["list"]
    description  = "Allow listing of roles"
  }

  rule {
    path         = "auth/+/roles"
    capabilities = ["list"]
    description  = "Allow listing of roles"
  }

  rule {
    path         = "auth/+/role/+"
    capabilities = ["create", "read", "update", "delete"]
    description  = "Allow managing of roles"
  }

  rule {
    path         = "auth/+/role/+/tag"
    capabilities = ["update"]
    description  = "Manage AWS role tags"
  }

  rule {
    path         = "auth/+/roletag-denylist/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "Manage AWS roletag denylists"
  }

  rule {
    path         = "auth/+/tidy/roletag-denylist"
    capabilities = ["update"]
    description  = "Tidy AWS roletag denylists"
  }

  rule {
    path         = "auth/+/identity-accesslist/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "Manage AWS identity access lists"
  }

  rule {
    path         = "auth/+/tidy/identity-accesslist"
    capabilities = ["update"]
    description  = "Tidy AWS identity access lists"
  }

  rule {
    path         = "auth/+/role/+/secret-id"
    capabilities = ["list"]
    description  = "Allow listing AppRole Secret ID Accessors"
  }

  rule {
    path         = "auth/+/role/+/secret-id/lookup"
    capabilities = ["update"]
    description  = "Allow looking up AppRole Secret ID"
  }

  rule {
    path         = "auth/+/role/+/secret-id/destroy"
    capabilities = ["update"]
    description  = "Allow deleting AppRole Secret ID"
  }

  rule {
    path         = "auth/+/role/+/secret-id-accessor/lookup"
    capabilities = ["update"]
    description  = "Allow looking up AppRole Secret ID"
  }

  rule {
    path         = "auth/+/role/+/secret-id-accessor/destroy"
    capabilities = ["update"]
    description  = "Allow deleting AppRole Secret ID"
  }

  rule {
    path         = "auth/+/tidy/secret-id"
    capabilities = ["update"]
    description  = "Allow tidy of AppRole tokens"
  }

  rule {
    path         = "auth/+/map/+/*"
    capabilities = ["read", "update"]
    description  = "Allow configuring GitHub mappings"
  }

  rule {
    path         = "auth/+/role/+/service-accounts"
    capabilities = ["update"]
    description  = "Allow editing Service Accounts on GCP Role"
  }

  rule {
    path         = "auth/+/role/+/labels"
    capabilities = ["update"]
    description  = "Allow editing Labels on GCP Role"
  }

  rule {
    path         = "auth/+/groups/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "Allow managing Kerberos/LDAP/Okta groups"
  }

  rule {
    path         = "auth/+/users/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "Allow managing LDAP/Okta/RADIUS/Userpass users"
  }

  rule {
    path         = "auth/+/certs/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "Allow managing TLS auth certs"
  }

  rule {
    path         = "auth/+/crls/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "Allow managing TLS auth CRLs"
  }

  rule {
    path         = "auth/+/accessors"
    capabilities = ["list"]
    description  = "List token accessors"
  }

  rule {
    path         = "auth/+/lookup"
    capabilities = ["update"]
    description  = "Allow looking up token details"
  }

  rule {
    path         = "auth/+/lookup-accessor"
    capabilities = ["update"]
    description  = "Allow looking up token details"
  }

  rule {
    path         = "auth/+/revoke"
    capabilities = ["update"]
    description  = "Allow revoking a token"
  }

  rule {
    path         = "auth/+/revoke-accessor"
    capabilities = ["update"]
    description  = "Allow revoking a token"
  }

  rule {
    path         = "auth/+/revoke-orphan"
    capabilities = ["update"]
    description  = "Allow revoking a token"
  }

  rule {
    path         = "auth/+/tidy"
    capabilities = ["update"]
    description  = "Tidy token store"
  }

  rule {
    path         = "auth/+/users/+/password"
    capabilities = ["update"]
    description  = "Allow reseting a userpass user's password"
  }

  rule {
    path         = "auth/+/users/+/policies"
    capabilities = ["update"]
    description  = "Allow reseting a userpass user's policies"
  }

  rule {
    path         = "+/config/*"
    capabilities = ["read", "update", "delete", "list"]
    description  = "Allow managing secret engine configs"
  }

  rule {
    path         = "+/roles/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "Allow managing secret roles"
  }

  rule {
    path         = "+/static-roles/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "Allow managing secret roles"
  }

  rule {
    path         = "+/library"
    capabilities = ["list"]
    description  = "Allow listing AD Libraries"
  }

  rule {
    path         = "+/library/+"
    capabilities = ["create", "read", "update", "delete"]
    description  = "Allow managing AD Libraries"
  }

  rule {
    path         = "+/library/manage/+/check-in"
    capabilities = ["create", "read", "update", "delete"]
    description  = "Allow forcing AD library check-in"
  }

  rule {
    path         = "+/library/+/status"
    capabilities = ["read"]
    description  = "Allow reading AD Library status"
  }

  rule {
    path         = "+/rotate-root/*"
    capabilities = ["read", "update"]
    description  = "Allow rotating root credentials"
  }

  rule {
    path         = "+/rotate/+"
    capabilities = ["update"]
    description  = "Allow rotating role credentials"
  }

  rule {
    path         = "+/rotate-role/+"
    capabilities = ["update"]
    description  = "Allow rotating role credentials"
  }

  rule {
    path         = "+/reset/+"
    capabilities = ["update"]
    description  = "Allow reseting database connections"
  }

  rule {
    path         = "+/rolesets"
    capabilities = ["list"]
    description  = "Allow listing GCP rolesets"
  }

  rule {
    path         = "+/roleset/+"
    capabilities = ["create", "read", "update", "delete"]
    description  = "Allow managing GCP rolesets"
  }

  rule {
    path         = "+/roleset/+/rotate-key"
    capabilities = ["update"]
    description  = "Allow rotating GCP roleset key"
  }

  rule {
    path         = "+/static-accounts"
    capabilities = ["list"]
    description  = "Allow listing GCP static accounts"
  }

  rule {
    path         = "+/static-account/+"
    capabilities = ["create", "read", "update", "delete"]
    description  = "Allow managing GCP static accounts"
  }

  rule {
    path         = "+/static-account/+/rotate-key"
    capabilities = ["update"]
    description  = "Allow rotating GCP static account key"
  }

  rule {
    path         = "+/keys/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "Allow managing GCP KMS keys"
  }

  rule {
    path         = "identity/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "Allow managing Identities"
  }

  rule {
    path         = "+/metadata/*"
    capabilities = ["read", "list"]
    description  = "Allow listing KVv2 secrets"
  }

  rule {
    path         = "+/subkeys/*"
    capabilities = ["read"]
    description  = "Allow reading of KVv2 subkeys"
  }

  rule {
    path         = "sys/*"
    capabilities = ["read", "list", "sudo"]
    description  = "Allow viewing system configuration settings"
  }

  rule {
    path         = "sys/auth/*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    description  = "Allow managing auth mounts"
  }

  rule {
    path         = "sys/mounts/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "Allow managing secret mounts"
  }

  rule {
    path         = "sys/policies/*"
    capabilities = ["create", "read", "update", "delete"]
    description  = "Allow managing policies"
  }

  rule {
    path         = "sys/step-down"
    capabilities = ["update", "sudo"]
  }

}

resource "vault_policy" "user7" {
  name   = "admin_policy"
  policy = data.vault_policy_document.user7.hcl
}

resource "vault_generic_endpoint" "user7" {
  depends_on = [vault_auth_backend.userpass]

  path                 = "auth/${vault_auth_backend.userpass.path}/users/user7"
  ignore_absent_fields = true

  data_json = jsonencode({
    "policies" = ["${vault_policy.user7.name}"],
    "password" = "changeme"
  })
}

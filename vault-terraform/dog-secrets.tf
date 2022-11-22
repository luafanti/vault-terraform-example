## ---------------------------------------------------------------------------------------------------------------------
## KV Secrets Engine - Version 2
## ---------------------------------------------------------------------------------------------------------------------

resource "vault_mount" "dog-kv-v2" {
  path = "dog-kv-v2"
  type = "kv-v2"
}

resource "vault_kv_secret_v2" "dog_credentials" {
  mount               = vault_mount.dog-kv-v2.path
  name                = "credentials"
  delete_all_versions = true
  data_json = jsonencode(
    {
      user     = "dog",
      password = "dog-pass"
    }
  )
}

## ---------------------------------------------------------------------------------------------------------------------
## PostgreSQL Database Secrets Engine
## ---------------------------------------------------------------------------------------------------------------------

resource "vault_database_secrets_mount" "dog-db" {
  path = "dog-db"

  postgresql {
    name              = "postgres"
    username          = var.postgres_username
    password          = var.postgres_password
    connection_url    = "postgresql://{{username}}:{{password}}@${var.postgres_host}:5432"
    verify_connection = true
    allowed_roles = [
      "dog*",
    ]
  }
}

resource "vault_database_secret_backend_role" "dog_dynamic_role" {
  name        = "dog-dynamic-role"
  backend     = vault_database_secrets_mount.dog-db.path
  db_name     = vault_database_secrets_mount.dog-db.postgresql[0].name
  default_ttl = 600
  max_ttl     = 600

  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';",
    "GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";",
  ]

}

## ---------------------------------------------------------------------------------------------------------------------
## Transit Secrets Engine
## ---------------------------------------------------------------------------------------------------------------------

resource "vault_mount" "dog_transit" {
  path                      = "dog-transit"
  type                      = "transit"
  description               = "Transit backend for Dog user"
  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 86400
}

resource "vault_transit_secret_backend_key" "dog_transit_key" {
  backend = vault_mount.dog_transit.path
  name    = "dog_transit_key"

  exportable             = true
  allow_plaintext_backup = true
}
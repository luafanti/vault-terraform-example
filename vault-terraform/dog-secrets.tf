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

resource "vault_database_secrets_mount" "dog-db" {
  path = "dog-db"

  postgresql {
    name              = "postgres"
    username          = "postgres"
    password          = "postgres"
    connection_url    = "postgresql://{{username}}:{{password}}@10.100.213.0:5432"
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

#resource "vault_database_secret_backend_static_role" "dog_static_role" {
#  name                = "dog-static-role"
#  backend             = vault_database_secrets_mount.dog-db.path
#  db_name             = vault_database_secrets_mount.dog-db.postgresql[0].name
#
#  username            = "dog-static"
#  rotation_period     = "3600"
#  rotation_statements = ["ALTER USER \"{{name}}\" WITH PASSWORD '{{password}}';"]
#}
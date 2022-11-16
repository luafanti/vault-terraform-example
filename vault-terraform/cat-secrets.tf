resource "vault_mount" "cat-kv-v2" {
  path = "cat-kv-v2"
  type = "kv-v2"
}

resource "vault_kv_secret_v2" "cat_credentials" {
  mount               = vault_mount.cat-kv-v2.path
  name                = "credentials"
  delete_all_versions = true
  data_json = jsonencode(
    {
      user     = "cat",
      password = "cat-pass"
    }
  )
}

resource "vault_kv_secret_v2" "cat_secrets" {
  mount               = vault_mount.cat-kv-v2.path
  name                = "secrets"
  delete_all_versions = true
  data_json = jsonencode(
    {
      secret = "confidential"
    }
  )
}
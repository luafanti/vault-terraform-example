resource "vault_auth_backend" "userpass" {
  type = "userpass"
}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "kubernetes_auth" {
  backend         = vault_auth_backend.kubernetes.path
  kubernetes_host = "https://kubernetes.default"
}

resource "vault_auth_backend" "approle" {
  type = "approle"
}
resource "vault_policy" "cat_policy" {
  name   = "cat_policy"
  policy = file("policies/cat-client-policy.hcl")
}

resource "vault_generic_endpoint" "cat_user" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/cat"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "policies": ["cat_policy"],
  "password": "changeme"
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "cat_kubernetes_auth_role" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "cat_kubernetes_role"
  bound_service_account_names      = ["cat-auth"]
  bound_service_account_namespaces = [var.kubernetes_namespace]
  token_policies                   = ["cat_policy"]
  token_ttl                        = 3600
}
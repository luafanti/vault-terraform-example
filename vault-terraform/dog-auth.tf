resource "vault_policy" "dog_policy" {
  name   = "dog_policy"
  policy = file("policies/dog-client-policy.hcl")
}

resource "vault_generic_endpoint" "dog_user" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/dog"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "policies": ["dog_policy"],
  "password": "changeme"
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "dog_kubernetes_auth_role" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "dog_kubernetes_role"
  bound_service_account_names      = ["dog-auth"]
  bound_service_account_namespaces = [var.kubernetes_namespace]
  token_policies                   = ["dog_policy"]
  token_ttl                        = 3600
}
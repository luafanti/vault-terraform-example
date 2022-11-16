variable "kubernetes_namespace" {
  type        = string
  description = "Kubernetes working namespace"
  default     = "vault-poc"
}

variable "postgres_username" {
  type        = string
  description = "Username of vault PostgreSQL user"
}

variable "postgres_password" {
  type        = string
  description = "Password of vault PostgreSQL user"
}


variable "postgres_host" {
  type        = string
  description = "IP or DNS name of PostgresSQL service in k8s"
}
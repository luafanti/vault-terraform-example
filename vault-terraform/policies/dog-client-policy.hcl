path "dog-kv-v2/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "dog-db/creds/dog-dynamic-role" {
  capabilities = ["read"]
}
path "sys/leases/renew" {
  capabilities = ["create"]
}
path "sys/leases/revoke" {
  capabilities = ["update"]
}
path "dog-transit/encrypt/dog_transit_key" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "dog-transit/decrypt/dog_transit_key" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
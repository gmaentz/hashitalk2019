path "systemcreds/*" {
  capabilities = ["list"]
}
path "systemcreds/data/esxihosts/*" {
#  capabilities = ["list", "read"]
   capabilities = ["create", "update", "list", "read", "delete"]
  }
path "systemcreds/metadata/esxihosts/*" {
#  capabilities = ["list", "read"]
   capabilities = ["create", "update", "list", "read", "delete"]
  }
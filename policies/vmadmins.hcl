# Allows admins to read passwords.
path "systemcreds/*" {
  capabilities = ["list"]
}
path "systemcreds/data/esxihosts/*" {
  capabilities = ["list", "read"]
}
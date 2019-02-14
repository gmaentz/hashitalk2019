path "systemcreds/data/vmware/*" {
  capabilities = ["create", "update"]
}

# Allow hosts to generate new passphrases
path "gen/passphrase" {
  capabilities = ["update"]
}

# Allow hosts to generate new passwords
path "gen/password" {
  capabilities = ["update"]
}
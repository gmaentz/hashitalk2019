# Script for rotating passwords on ESXi accounts.
# Make sure and set VAULT_TOKEN and VAULT_ADDR as environment variables.
# You may run this script as a scheduled task for regular rotation.

# Still need to implement TLS
# Use TLS
# [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Import some environment variables.
# $VAULT_ADDR = $env:VAULT_ADDR
$VAULT_ADDR='http://127.0.0.1:8200'
$VAULT_TOKEN = 's.13316a99AQHsXVlpJyPO9oI6'
#$VAULT_TOKEN = $env:VAULT_TOKEN
$ESXIHOSTNAME = "esxihost20"

# Renew our token before we do anything else.
# Invoke-RestMethod -Headers @{"X-Vault-Token" = ${VAULT_TOKEN}} -Method POST -Uri ${VAULT_ADDR}/v1/auth/token/renew-self
# if(-Not $?)
# {
#    Write-Output "Error renewing Vault token lease."
# }

# Fetch a new passphrase from Vault. Adjust the options to fit your requirements.
#$NEWPASS = (Invoke-RestMethod -Headers @{"X-Vault-Token" = ${VAULT_TOKEN}} -Method POST -Body "{`"words`":`"4`",`"separator`":`"-`"}" -Uri ${VAULT_ADDR}/v1/gen/passphrase).data.value

# Generate a Random password - still need to implement this plugin or order to work
# Fetch a new password from Vault. Adjust the options to fit your requirements.
# $NEWPASS = (Invoke-RestMethod -Headers @{"X-Vault-Token" = ${VAULT_TOKEN}} -Method POST -Body "{`"length`":`"36`",`"symbols`":`"0`"}" -Uri ${VAULT_ADDR}/v1/gen/password).data.value

$USERNAME = "root"
$NEWPASS = "NewP@ssw0rd1"

# Convert into a SecureString
$SECUREPASS = ConvertTo-SecureString $NEWPASS -AsPlainText -Force

# Create the JSON payload to write to Vault's K/V store. 
# Keep the last 10 versions of this credential.
$JSON="{ `"options`": { `"max_versions`": 10 }, `"data`": { `"$USERNAME`": `"$NEWPASS`" } }"

# First commit the new password to vault, then change it locally.
Invoke-RestMethod -Headers @{"X-Vault-Token" = ${VAULT_TOKEN}} -Method POST -Body $JSON -Uri ${VAULT_ADDR}/v1/systemcreds/data/vmware/${ESXIHOSTNAME}/${USERNAME}_creds

if($?) {
   Write-Output "Vault updated with new password for $ESXIHOSTNAME"
   Write-Output $USERNAME
   Write-Output $SECUREPASS

   # PowerCLI command here to update the root password - TODO
   # Enhancement would be to query for ESXi Hostname $ESXIHOSTNAME

   if($?) {
       Write-Output "${USERNAME}'s password was stored in Vault and updated on the ESXi host - $ESXIHOSTNAME"
   }
   else {
       Write-Output "Error: ${USERNAME}'s password was stored in Vault but *not* on the ESXi host - $ESXIHOSTNAME"
   }
}
else {
    Write-Output "Error saving new password to Vault. ESXi password will remain unchanged."
}
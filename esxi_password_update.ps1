# Script for rotating root passwords on ESXi accounts.
# Pass the VAULT_TOKEN, VAULT_ADDR and VCENTER_ADDR as parameters.

param (
    [Parameter(Mandatory=$true)][string]$vcenter,
    [Parameter(Mandatory=$true)][string]$vaultserver,
    [Parameter(Mandatory=$true)][string]$vaulttoken
 )

 write-output "VCenter Server: $vcenter"
 write-output "Vault Server: $vaultserver"
 write-output "Vault Token: $vaulttoken"

# Connect to vCenter or ESXi Host and enumerate hosts to be updated
Connect-VIServer $vcenter
$hosts = @()
Get-VMHost | sort | Get-View | Where {$_.Summary.Config.Product.Name -match "i"} | % { $hosts+= $_.Name }
Disconnect-VIServer -confirm:$false

# How many versions to keep
# $JSON="{ `"options`": { `"max_versions`": 10 }, `"data`": { `"$USERNAME`": `"$NEWPASS`" } }

#Connect to Vault and read in old password
foreach ($vmhost in $hosts) {
    $jsondata = Invoke-RestMethod -Headers @{"X-Vault-Token" = $vaulttoken} -Uri $vaultserver/v1/systemcreds/data/esxihosts/$vmhost
    $oldpw = $jsondata.data.data.password
    write-host "Root password for $vmhost is $oldpw" 
}

#Connect to each ESXi host and change pw while logging password into Vault
foreach ($vmhost in $hosts) {
    # Read in current password from Vault
    $jsondata = Invoke-RestMethod -Headers @{"X-Vault-Token" = $vaulttoken} -Uri $vaultserver/v1/systemcreds/data/esxihosts/$vmhost
    $oldpw = $jsondata.data.data.password

    # Random Password Generator
    $newpw = [system.web.security.membership]::GeneratePassword(10,2)

    # First commit the new password to vault, then change it on the ESXi Server
    write-host "Updating Vault for $vmhost..."
    $JSON="{ `"options`": { `"max_versions`": 10 }, `"data`": { `"password`": `"$newpw`" } }"
    Invoke-RestMethod -Headers @{"X-Vault-Token" = $vaulttoken} -Method POST -Body $JSON -Uri $vaultserver/v1/systemcreds/data/esxihosts/$vmhost 
    write-host "Connecting to $vmhost..."
    Connect-VIserver -server $vmhost -user root -password "$oldpw"
    write-host "Changing root password on $vmhost..."
    Set-VMHostAccount -UserAccount root -password "$newpw"
    Disconnect-VIServer -confirm:$false
}


# Renew our token before we do anything else.
# Invoke-RestMethod -Headers @{"X-Vault-Token" = ${VAULT_TOKEN}} -Method POST -Uri ${VAULT_ADDR}/v1/auth/token/renew-self
# if(-Not $?)
# {
#    Write-Output "Error renewing Vault token lease."
# }

# Convert into a SecureString
# $SECUREPASS = ConvertTo-SecureString $NEWPASS -AsPlainText -Force

# Try Catch
# if($?) {
#    Write-Output "Vault updated with new password for $ESXIHOSTNAME"
#    Write-Output $USERNAME
#    Write-Output $SECUREPASS

#    # PowerCLI command here to update the root password - TODO
#    # connect-viserver host1.lab.local -user root -password "ze!(^^D:02"
   
#    Connect-VIServer $_.name -user root -password "ze!(^^D:02"
   
#    get-vmhost | ForEach-Object {
#     try {
#       Connect-VIServer $_ -User root -Password $CurrentPassword 
#       Set-VMHostAccount -UserAccount root -Password $NewPassword
#     } catch {
#       throw $_
#     } finally {
#       Disconnect-VIServer -Confirm:$False -ea -Out
#     }
#   }

# # Loop Through Hosts

#    if($?) {
#        Write-Output "${USERNAME}'s password was stored in Vault and updated on the ESXi host - $ESXIHOSTNAME"
#    }
#    else {
#        Write-Output "Error: ${USERNAME}'s password was stored in Vault but *not* on the ESXi host - $ESXIHOSTNAME"
#    }
# }
# else {
#     Write-Output "Error saving new password to Vault. ESXi password will remain unchanged."
# }
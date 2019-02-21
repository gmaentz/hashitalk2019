# Script for rotating root passwords on ESXi accounts.
# Random password is set for each host and stored in Vault
# Pass the vcenter, vaultserver, and vault token as parameters.
#
# Workflow:  
#   a. Login into vCenter and list all ESXi hosts
#   b. For each host read the current password from Vault.
#   c. Generate a new random password for each host.
#   d. Update Vault with the new password.
#   e. Update the ESXi host with the new password.

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

#Read in current Password from Vault, Generate New Password, Commit new password to Vault, Update the ESXi Server
foreach ($vmhost in $hosts) {
    # Read in current password from Vault
    $jsondata = Invoke-RestMethod -Headers @{"X-Vault-Token" = $vaulttoken} -Uri $vaultserver/v1/systemcreds/data/esxihosts/$vmhost
    if($?) {
        $currentpw = $jsondata.data.data.password
        
        # Random Password Generator - (Length,Special Characters)
        $newpw = [system.web.security.membership]::GeneratePassword(10,2)

        # First commit the new password to vault, then change it on the ESXi Server
        write-host "Updating Vault for $vmhost..."
        $JSON="{ `"options`": { `"max_versions`": 10 }, `"data`": { `"password`": `"$newpw`" } }"
        Invoke-RestMethod -Headers @{"X-Vault-Token" = $vaulttoken} -Method POST -Body $JSON -Uri $vaultserver/v1/systemcreds/data/esxihosts/$vmhost 
        if($?) {
            write-host "Connecting to $vmhost..."
            Connect-VIserver -server $vmhost -user root -password "$currentpw"
            write-host "Changing root password on $vmhost..."
            Set-VMHostAccount -UserAccount root -password "$newpw"
            Disconnect-VIServer -confirm:$false
            if($?) {
                Write-Output "Root password was stored in Vault and updated on ESXi host - $vmhost"
            }
            else {
                Write-Output "Error: Root password was stored in Vault but *not* changed on the ESXi host - $vmhost"
            }
        }
        else {
            Write-Output "Error saving new password to Vault. ESXi password will remain unchanged for $vmhost"
        }
     }
     else {
         Write-Output "Error reading password from Vault. Be sure a password is saved under the Vault path: /systemcreds/esxihosts/$vmhost"
     }
}
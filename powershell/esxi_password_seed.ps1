# Script for seeding Vault with ESXi credentials.
# Password is stored in Vault

param (
    [Parameter(Mandatory=$true)][string]$vcenter,
    [Parameter(Mandatory=$true)][string]$vaultserver,
    [Parameter(Mandatory=$true)][string]$hostpwd,
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

# Commit new password to Vault
foreach ($vmhost in $hosts) {
    # Commit the password to vault
    write-host "Updating Vault for $vmhost..."
    $JSON="{ `"options`": { `"max_versions`": 10 }, `"data`": { `"password`": `"$hostpwd`" } }"
    Invoke-RestMethod -Headers @{"X-Vault-Token" = $vaulttoken} -Method POST -Body $JSON -Uri $vaultserver/v1/systemcreds/data/esxihosts/$vmhost 
    if($?) {
        Write-Output "Error: Root password was stored in Vault but *not* changed on the ESXi host - $vmhost"
            }
        else {
            Write-Output "Error saving new password to Vault."
        }
}
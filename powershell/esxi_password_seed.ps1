# Performs a discovery of the VMware hosts within vCenter and 
# saves them to Vault with with a supplied password.
#
# Workflow:  
#   a. Login into vCenter and list all ESXi hosts
#   b. For each host set a specified password into Vault in the sytemcreds/esxihosts

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
        Write-Output "Root password was stored in Vault for ESXi host - $vmhost"
            }
        else {
            Write-Output "Error saving new password to Vault."
        }
}
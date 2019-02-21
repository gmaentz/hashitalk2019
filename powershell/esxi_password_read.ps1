# Read password for ESXi accounts stored in Vault.
# Pass the vcenter, vaultserver and vault token as parameters.
#
# Workflow:  
#   a. Login into vCenter and list all ESXi hosts
#   b. For each host read the current password from Vault.

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

#Connect to Vault and read in password
foreach ($vmhost in $hosts) {
    $jsondata = Invoke-RestMethod -Headers @{"X-Vault-Token" = $vaulttoken} -Uri $vaultserver/v1/systemcreds/data/esxihosts/$vmhost
    if($?) {
        $currentpw = $jsondata.data.data.password
        write-host "Root password for $vmhost is $currentpw"
     }
     else {
         Write-Output "Error reading password from Vault. Be sure a password is saved under the Vault path: /systemcreds/esxihosts/$vmhost"
     }
}
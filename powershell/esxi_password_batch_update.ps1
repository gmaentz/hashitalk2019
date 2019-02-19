# Connect to each ESXi host and set uniform password
# Password is not stored in any secure location

param (
    [Parameter(Mandatory=$true)][string]$vcenter,
    [Parameter(Mandatory=$true)][string]$currentpwd,
    [Parameter(Mandatory=$true)][string]$newpwd
 )

write-output "VCenter Server: $vcenter"

$hosts = @()
Get-VMHost | sort | Get-View | Where {$_.Summary.Config.Product.Name -match "i"} | % { $hosts+= $_.Name }
Disconnect-VIServer -confirm:$false

foreach ($vmhost in $hosts) {
    write-host "Connecting to $vmhost..."
    Connect-VIserver -server $vmhost -user root -password "$currentpwd"
    write-host "Changing root password on $vmhost..."
    Set-VMHostAccount -UserAccount root -password "$newpwd"
    if($?) {
        Write-Output "Root password was updated on ESXi host - $vmhost to $newpwd"
    }
    else {
        Write-Output "Error: Root password was *not* changed on the ESXi host - $vmhost"
    }
    Disconnect-VIServer -confirm:$false
}
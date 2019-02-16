param (
    [string]$server = "http://defaultserver",
    [Parameter(Mandatory=$true)][string]$vaulttoken
 )

 write-output $server
 write-output $vaulttoken
 
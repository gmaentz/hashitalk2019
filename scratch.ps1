$NewPassword = "VMware1!"
Set-VMHostAccount -UserAccount root -Password $NewPassword

get-vmhost | ForEach-Object {
    try {
      Write-Output $_ "Gabe"
    } catch {
      throw $_
    } finally {
    }
  }


# Login into vCenter
Connect-VIServer vc.lab.local

# Validate Current Password
$CurrentPassword = "VMware1!"
Connect-VIServer host1.lab.local -User root -Password $CurrentPassword

# Set New Password
$NewPassword = "P@ssw0rd1"

get-vmhost | ForEach-Object {
    try {
      Connect-VIServer $_ -User root -Password $CurrentPassword 
      Set-VMHostAccount -UserAccount root -Password $NewPassword
    } catch {
      throw $_
    } finally {
      Disconnect-VIServer -Confirm:$False
    }
  }

Host1 - VMware1!
Host2 - ze!(^^D:02
Host3 - ze!(^^D:02

get-vmhost | %{$null = connect-viserver $_.name -user root -password "VMware1!" -EA 0; if (-not ($?)) {write-warning "Password failed for $($_.name)"  } else {Disconnect-VIServer $_.name -force -confirm:$false} }

get-vmhost | Disconnect-VIServer $_.name -force -confirm:$false
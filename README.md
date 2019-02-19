# Managing VMware Environments with HashiCorp Vault

VMware is the virtualization standard within the corporate datacenter. An all too common practice is to use common passwords for the most privileged accounts within VMware environments. How many VM admins utilize the same root password for all of their ESXi servers? When was the last time your root password for ESXi servers was changed
There has to be a better way.

In this talk we will demonstrate how HashiCorp Vault can be used to help VMware Admins move to short-lived, dynamic credentials within ESXi and vSphere environments. Join us to learn: Why you would want to use dynamic credentials within your VMware environment to reduce security risks. Ways you can use HashiCorp Vault to manage, control and rotate VMWare credentials in an automated manner. How VMware Admins can utilize existing automation tools like vSphere API and PowerCLI with HashiCorp Vault.

VMware officially supports the Web Interface, PowerCLI and vSphere API.

## Evoloving VMware Secrets Managment
### Manual - UI
Changing an ESXi root password manually via the VMware Web interface.

![Manual - Web Interfaces](images/vault_packer_build.gif)

### Manual - PowerCLI
```
$CurrentPassword = "VMware1!"
$NewPassword = "NewP@ssw0rd"
Connect-VIServer host1.lab.local -User root -Password $CurrentPassword
Set-VMHostAccount -UserAccount root -Password $NewPassword
Disconnect-VIServer host1.lab.local -Confirm:$False
```

### Semi-Automated - PowerCLI / Host Profiles
Loop through all the hosts
![Host Profiles (VMware Enterprise+ customers only)](images/host_profiles.gif)

esxi_password_batch_update.ps1
![Batch Update - PowerCLI](images/vault_packer_build.gif)


## Automated - PowerCLI and HashiCorp Vault
## Vault Setup
### Step 1: Configure Policies
vault policy write rotate-esxi policies/rotate-esxi.hcl

### Step 2: Generate a Token
vault token create -period 24h -policy rotate-esxi

### Step 3: Run the script
```powershell  .\esxi_password_update.ps1
   -vcenter vc.lab.local 
   -vaultserver
   -token
```
Example:
```.\esxi_password_update.ps1 -vcenter vc.lab.local -vaultserver https://vault.lab.local:8200 -token
```
![Automated - Read and Update Vault](images/read_update_vault.gif)

Automated PowerCLI, REST API to rotate passwords, unique password for all hosts, changed dynamically and still allows for manual revoke and updates
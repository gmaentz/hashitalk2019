# Managing VMware Environments with HashiCorp Vault

VMware is the virtualization standard within the corporate datacenter. An all too common practice is to use common passwords for the most privileged accounts within VMware environments. How many VM admins utilize the same root password for all of their ESXi servers? When was the last time your root password for ESXi servers was changed
There has to be a better way.

In this talk we will demonstrate how HashiCorp Vault can be used to help VMware Admins move to short-lived, dynamic credentials within ESXi and vSphere environments. Join us to learn: Why you would want to use dynamic credentials within your VMware environment to reduce security risks. Ways you can use HashiCorp Vault to manage, control and rotate VMWare credentials in an automated manner. How VMware Admins can utilize existing automation tools like vSphere API and PowerCLI with HashiCorp Vault.

VMware officially supports the Web Interface, PowerCLI and vSphere API.

## Evoloving VMware Secrets Managment
### Manual - UI
Changing an ESXi root password manually via the VMware Web interface.

### Manual - PowerCLI
Changing an ESXi root password manually via PowerCLI.
```
$CurrentPassword = "VMware1!"
$NewPassword = "NewP@ssw0rd"
Connect-VIServer host1.lab.local -User root -Password $CurrentPassword
Set-VMHostAccount -UserAccount root -Password $NewPassword
Disconnect-VIServer host1.lab.local -Confirm:$False
```
![Manual - Web Interfaces](images/manual.gif)

### Semi-Automated - Host Profiles / PowerCLI
### Host Profiles - UI
Changing an ESXi root password manually via the VMware Web interface.
Loop through all the hosts
![Host Profiles (VMware Enterprise+ customers only)](images/host_profiles.gif)
### Mass Update - PowerCLI
Changing the ESXi root password of all hosts via PowerCLI.
esxi_password_batch_update.ps1

![Batch Update - PowerCLI](images/batch_update.gif)

## Automated - PowerCLI and HashiCorp Vault
Automated PowerCLI, REST API to rotate passwords, unique password for all hosts, changed dynamically and still allows for manual revoke and updates

## Prerequisites / Vault Setup
* HashiCorp Vault cluster that is reachable from your server instances. (Inbound TCP port 8200 to Vault)

### Step 1: Configure Policies
* Create a vmadmins policy
* Upload the vmadmins.hcl into the ACL policies with the Vault UI

```
vault policy write vmadmins policies/vmadmins.hcl
```
### Step 2: Associate the vmadmins policy with the LDAP Group or user pass
LDAP Authentication
```
vault write "auth/ldap/groups/VMware Admins" policies=vmadmins
```
User Name Password Authentication
```
vault write auth/userpass/users/vmadmin password=VMware1! policies=vmadmins
```
### Step 3: Login as the User and Generate a Token
```
vault token create -period 24h -policy vmadmins
```
### Step 4: Enable the KV secrets engine
A version 2 K/V secrets backend mounted at `systemcreds`

### Step 5: Run the script
```
powershell  .\esxi_password_update.ps1 -vcenter {vcenter} -vaultserver {vault server -vaulttoken {vaulttoken}
```
Example:
```
.\esxi_password_update.ps1 -vcenter vc.lab.local -vaultserver https://vault.lab.local:8200 -vaulttoken
```
![Automated - Read and Update Vault](images/read_update_vault.gif)


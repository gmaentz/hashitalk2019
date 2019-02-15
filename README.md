# Managing VMware Environments with HashiCorp Vault

VMware is the virtualization standard within the corporate datacenter. An all too common practice is to use common passwords for the most privileged accounts within VMware environments. How many VM admins utilize the same root password for all of their ESXi servers? When was the last time your root password for ESXi servers was changed
There has to be a better way.

In this talk we will demonstrate how HashiCorp Vault can be used to help VMware Admins move to short-lived, dynamic credentials within ESXi and vSphere environments. Join us to learn: Why you would want to use dynamic credentials within your VMware environment to reduce security risks. Ways you can use HashiCorp Vault to manage, control and rotate VMWare credentials in an automated manner. How VMware Admins can utilize existing automation tools like vSphere API and PowerCLI with HashiCorp Vault.

VMware officially supports the API and PowerCLI

### Discovering Passwords for ESXi Servers
Below is a PowerCLI one-liner you can use to validate if all your root passwords are what you expect them to be.

```
$CurrentPassword = "VMware1!"
get-vmhost | %{$null = connect-viserver $_.name -user root -password $CurrentPassword -EA 0; if (-not ($?)) {write-warning "Password failed for $($_.name)"  } else {Disconnect-VIServer $_.name -force -confirm:$false} }
```


## Evoloving VMware Secrets Managment
### Manual - UI

### Manual - CLI
$CurrentPassword = "VMware1!"
$NewPassword = "VMware1!"
Connect-VIServer host1.lab.local -User root -Password $CurrentPassword
Set-VMHostAccount -UserAccount root -Password $NewPassword
Disconnect-VIServer -Confirm:$False -ea -Out

### Semi-Automated

## vSphere API

Show the vSphere REST API
https://your_vcenter.server.com/apiexplorer

Resetting a root password with vSphere API

Get Hosts from vCenter
https://your_vcenter.server.com/rest/vcenter/host


* Also works with Ansible for looping through hosts and then getting the root credentials from Vault

Shows the curl command that you can use in your cu
Set the environment variables


## PowerCLI

1. Set the environment variables
2. Install the random secret generator inside vault
3. Create the data path in vault for ESXi Servers

### Step 1: Configure Policies
vault policy write rotate-esxi policies/rotate-esxi.hcl

### Step 2: Generate a Token for each ESXi Server
vault token create -period 24h -policy rotate-esxi

### Step 3: Put the token onto each instance
Append the following lines to /etc/environment.
```
export VAULT_ADDR=http://your_vault.server.com:8200
export VAULT_TOKEN=4ebeb7f9-d691-c53f-d8d0-3c3d500ddda8
```
Example:
```
export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_TOKEN=s.53uBQcDhcM4Jiq8tnJ9BLS5a
```

### Step 4: Run the script
```powershell
.\esxi_password_update.ps1 root
```

# Same password across multiple hosts
vault kv put systemcreds/esxihosts/esxihost01 password=P@ssw0rd!
vault kv put systemcreds/esxihosts/esxihost02 password=P@ssw0rd!


vault kv get systemcreds/esxihosts/esxihost01
vault kv get -field=password  systemcreds/esxihosts/esxihost01

 Versions

vault kv put systemcreds/esxihosts/esxihost01 password=NewP@ssword!

# API
## Create the KV store
curl \
    --header "X-Vault-Token: s.13316a99AQHsXVlpJyPO9oI6" \
    --request POST \
    --data @payload.json \
    http://127.0.0.1:8200/v1/secret/config

## Create a secret in the KV store

curl \
    --header "X-Vault-Token: s.13316a99AQHsXVlpJyPO9oI6" \
    --request POST \
    --data @payload2.json \
    http://127.0.0.1:8200/v1/secret/data/esxihosts/esxihost01 | jq



## Read from the KV store
curl \
    --header "X-Vault-Token: s.13316a99AQHsXVlpJyPO9oI6" \
    http://127.0.0.1:8200/v1/secret/config


curl \
    --header "X-Vault-Token: s.13316a99AQHsXVlpJyPO9oI6" \
    http://127.0.0.1:8200/v1/systemcreds/esxihosts/esxihost01/password
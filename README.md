# hashitalk2019

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
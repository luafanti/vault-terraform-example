# HashiCorp Vault - terraform examples

Example of Vault resources definition as a code with Terraform.

## Prerequisites

You have to use your own k8s cluster. It can be minikube, k3s or any other local distribution.


#### k8s

First of all create dedicated k8s namespace and set terraform variable `kubernetes_namespace` under `/vault-terraform`.

```
kubectl create ns vault-poc
kubectl config set-context --current --namespace=vault-poc
```

#### Vault 

Easiest way to install Vault is using Helm chart.
The Vault Helm chart defaults to run in standalone mode. This installs a single Vault server with a file storage backend.

```
helm repo add hashicorp https://helm.releases.hashicorp.com
helm install vault hashicorp/vault
```

After the Vault Helm chart is installed Vault servers need to be initialized. The initialization generates the credentials necessary to unseal Vault.
To simplifying we initialize Vault with single Unseal Key.

```
kubectl exec vault-0 -- vault operator init \
    -key-shares=1 \
    -key-threshold=1 \
    -format=json > vault-keys.json
```

Using `unseal_keys_hex` from output `vault-keys.json` we can unseal vault server.

```
kubectl exec -ti vault-0 -- vault operator unseal <unseal_key>
```

Now our Vault server is ready to operate.

```
kubectl exec -it vault-0 vault status

# should retrun 'Sealed = false' adn vault-0 pod should be in Running state
```

You can now update `token` in terraform provider `vault-terraform/main.tf` with `root_token` from output `vault-keys.json`.
This same root token you can use to authorize in Vault UI.

```
kubectl port-forward svc/vault 8200:8200
```

Set also `address` in `vault-terraform/main.tf` accordingly to your port-forwarding setup.

#### PostgreSQL

PostgreSQL instance is required to evaluate Vault [Dynamic secrets](https://developer.hashicorp.com/vault/docs/secrets/databases) for database.
We can also use Helm chart to simplify installation of PostgreSQL in k8s.

```
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install psql bitnami/postgresql

```

Set PostgreSQL credentials in terraform variables under `/vault-terraform`.

```
# obtain PostgreSQL root password
kubectl get secret --namespace vault-poc psql-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d

# obtain PostgreSQL IP address
kubectl get svc
```

## Install Vault resources

Once you set up all terraform variables and provider config you can try to install resource with Terraform.

```
cd vault-terraform
tf init 
tf apply 
```

For better understanding, I created separate resources for `dog` and `cat`. 
These entities can be treated as separate clients or separate applications.

Terraform will install belows:
* Dedicated policies for `cat` and `dog`
* KV Secrets Engine - Version 2 for `cat` with two secrets entries
* KV Secrets Engine - Version 2 for `dog` with single secret entry
* PostgreSQL Database Secrets Engine for `dog`
* PostgreSQL Database Dynamic Role for `dog` to generate dynamic database credentials
* Userpass Auth Method for `cat` and `dog`
* Kubernetes Auth Method for `cat` and `dog` to inject secrets from Vault to pods using [Vault Agent Injector](https://developer.hashicorp.com/vault/docs/platform/k8s/injector)

Using userpass auth you can evaluate if policies permissions works appropriate.

```
# exec into vault pod
kubectl exec -it vault-0 /bin/sh

# login as cat user. Password is 'changeme'
vault login -method=userpass username=cat

# read kv-v2 credentials
vault kv get cat-kv-v2/credentials

# login as dog user. Password is 'changeme'
vault login -method=userpass username=dog

# read kv-v2 credentials
vault kv get dog-kv-v2/credentials

# generate dynamic PostgreSQL crednetials
vault read dog-db/creds/dog-dynamic-role
```

Now you can test how works [Vault Agent Injector](https://developer.hashicorp.com/vault/docs/platform/k8s/injector).
Install `cat` and `dog` nginx pods with predefined [Agent Injector annotations](https://developer.hashicorp.com/vault/docs/platform/k8s/injector/annotations).

```
kubectl apply -f ../k8s/
```

You can evaluate result with:

```
# cat kv-v2 secrets formated with template
kubectl exec cat-nginx -c nginx -- cat /vault/secrets/config.txt

# cat kv-v2 secrets injected as envs
kubectl exec cat-nginx -c nginx -- cat /vault/secrets/test

# dog dynamic secrets from PostgreSQL
kubectl exec dog-nginx -c nginx -- cat /vault/secrets/db.txt
```
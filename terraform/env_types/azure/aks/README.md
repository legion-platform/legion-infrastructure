# Prerequisities

- Create Azure Service Principal account.
- In Azure cloud console, login as service principal:
```bash
$ az login --service-principal -u CLIENT_ID -p CLIENT_SECRET --tenant TENANT_ID
```

- Create resource group for Terraform remote backend and all base resources of AKS cluster:
```bash
$ export RG="legion-test"
$ az group create --name $RG --location eastus --tags environment=Testing cluster=legion
```

- Create public IP that will be used as Kubernetes cluster endpoint
```bash
$ export CLUSTER_NAME="legion-test"
$ az network public-ip create --name $CLUSTER_NAME --resource-group $RG --allocation-method Static \
    --sku Standard --version IPv4 --tags environment=Testing cluster=$CLUSTER_NAME purpose="Kubernetes cluster endpoint"
```

- Create storage account in this storage group:
```bash
$ export AZURE_STORAGE_ACCOUNT="storage7868768" # Some unique name without dashes, underscores and capitals
$ az storage account create --resource-group $RG \
	--name $AZURE_STORAGE_ACCOUNT --sku Standard_LRS --encryption-services blob \
	--tags environment=Testing purpose="Terraform Backend storage"
```

- Create storage container (aka blob bucket):
```bash
$ export AZURE_STORAGE_KEY=$(az storage account keys list --resource-group $RG \
    --account-name $AZURE_STORAGE_ACCOUNT --query [0].value -o tsv)
$ export STORAGE_CONTAINER="tfstates-bucket"
$ az storage container create --name $STORAGE_CONTAINER --account-name $AZURE_STORAGE_ACCOUNT --account-key $AZURE_STORAGE_KEY \
	--metadata environment=Testing purpose="Terraform Backend storage"
```
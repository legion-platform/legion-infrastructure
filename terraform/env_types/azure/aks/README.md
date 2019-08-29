# Prerequisities

grab some beer

- Create Azure Service Principal account.
- In Azure cloud console, login as service principal:
```bash
$ az login --service-principal -u CLIENT_ID -p CLIENT_SECRET --tenant TENANT_ID
```

- Create storage group for Terraform remote backend:
```bash
$ az group create --name my-fancy-tfstates --location eastus --tags environment=Testing purpose="Terraform Backend storage"
```

- Create storage account in this storage group:
```bash
$ export AZURE_STORAGE_ACCOUNT="myfancytfstates"
$ az storage account create --resource-group epmd-legn-tfstates \
	--name $AZURE_STORAGE_ACCOUNT --sku Standard_LRS --encryption-services blob \
	--tags environment=Testing purpose="Terraform Backend storage"
```

- Create storage container (aka blob bucket):
```bash
$ export AZURE_STORAGE_KEY=$(az storage account keys list --resource-group epmd-legn-tfstates \
    --account-name $AZURE_STORAGE_ACCOUNT --query [0].value -o tsv)
$ export STORAGE_CONTAINER="tfstates-bucket"
$ az storage container create --name $STORAGE_CONTAINER --account-name $AZURE_STORAGE_ACCOUNT --account-key $AZURE_STORAGE_KEY \
	--metadata environment=Testing purpose="Terraform Backend storage"
```
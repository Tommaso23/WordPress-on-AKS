# Wordpress on Azure Kubernetes Service: Step-by-Step Guide
This repo contains the initial setup requ
![Architecture Diagram](./images/hubspoke.png)
*Figure 1: Hub and Spoke Network Architecture*

## 1: Deploy
### Prerequisites
### Deployment


[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FTommaso23%2FWordpress-on-AKS%2Frefs%2Fheads%2Fmain%2Fazuredeploy.json)


1 namespace.yaml
2 pv-nfs.yaml
3 pvc-nfs.yaml
4 nginx-internal-controller.yaml (questo crea Managed Identity e kubernetes-internal in MC_rg)
5 nginx.yaml

Prima di deployare "secretprovider.yaml" recupera:
    - userAssignedIdentityID: 
        az aks show --resource-group <resource-group> --name <cluster-name> --query addonProfiles.azureKeyvaultSecretsProvider.identity.clientId -o tsv
    - keyVaultName 
    - serve anche tenant_id
6 secretprovider.yaml
7 deployment-wp.yaml

$IDENTITY_OBJECT_ID="$(az identity show --resource-group MC_rg-aks-test-itn_aks-bcp-itn_italynorth --name azurekeyvaultsecretsprovider-aks-bcp-itn --query 'principalId' -o tsv)"
$KEYVAULT_SCOPE=$(az keyvault show --name kv-bcp-njff4zl344wqc-itn --query id -o tsv)

# Example command for key vault with RBAC enabled using `key` type
az role assignment create --role "Key Vault Secrets User" --assignee b4dab3cf-4591-44ed-9201-d7d17d6de819 --scope /subscriptions/c22222e4-89fd-49ec-9ba0-3b33436cfd42/resourceGroups/rg-aks-bcp-itn/providers/Microsoft.KeyVault/vaults/kv-bcp-njff4zl344wqc-itn
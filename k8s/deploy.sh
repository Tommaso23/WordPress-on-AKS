
#Connecting to the AKS cluster with az aks get-credentials...
#!/bin/bash

rg="rg-aks-norm-itn"  # Replace with your resource group name
cluster="aks-norm-itn"  # Replace with your AKS cluster name
netappvolume="vol-norm-itn" # Replace with your NetApp volume name

echo "Connecting to AKS cluster..."
az aks get-credentials --resource-group "$rg" --name "$cluster" --overwrite-existing

echo "Fetching parameters from Azure..."
clientid=$(az aks show --resource-group "$rg" --name "$cluster" \
  --query addonProfiles.azureKeyvaultSecretsProvider.identity.clientId -o tsv)

keyvaultname=$(az keyvault list --resource-group "$rg" --query "[0].name" -o tsv)

tenantid=$(az account show --query tenantId -o tsv)

echo "Client ID: $clientid"
echo "Key Vault: $keyvaultname"
echo "Tenant ID: $tenantid"
echo "NetApp Volume: $netappvolume"

export clientid keyvaultname tenantid netappvolume

# Generate final secretprovider.yaml and persistentvolume.yaml with actual values
echo "Generating 'secretprovider.yaml' from template..."
envsubst < k8s/wordpress/secretprovider-temp.yaml > k8s/wordpress/secretprovider.yaml
envsubst < k8s/wordpress/pv-wp-temp.yaml > k8s/wordpress/pv-wp.yaml

# Apply Kubernetes manifests in order
echo "Deploying YAML files to the cluster..."
cd wordpress

kubectl apply -f namespace.yaml
kubectl apply -f pv-wp.yaml
kubectl apply -f pvc-wp.yaml
kubectl apply -f nginx-internal-controller.yaml
kubectl apply -f nginx.yaml
kubectl apply -f secretprovider.yaml
kubectl apply -f deployment-wp.yaml
kubectl apply -f service-wp.yaml

echo "✅ Deployment completed successfully!"



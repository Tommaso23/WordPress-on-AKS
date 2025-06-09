# Wordpress on Azure Kubernetes Service
This repo contains the initial setup required to...
![Architecture Diagram](./architecture.svg)

*Download the [architecture.vsdx](./architecture.vsdx) file of the architecture*


## 1: Deploy
### Prerequisites
### Deployment


[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FTommaso23%2FWordpress-on-AKS%2Frefs%2Fheads%2Fmain%2Fazuredeploy.json)



The az aks get-credentials command will be fetch a kubeconfig containing references to the AKS cluster you have created earlier.

minimum kubectl version: 1.30.x
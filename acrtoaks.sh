
#!/bin/bash

# Replace these variables with your actual values
ACR_NAME="registrypfa"
AKS_RESOURCE_GROUP="AKS-resource-group"
AKS_CLUSTER_NAME="cluster-dev-aks"

# Get the ACR resource ID
echo "Getting ACR resource ID..."
ACR_ID=$(az acr show --name $ACR_NAME --query id --output tsv)

if [ -z "$ACR_ID" ]; then
  echo "Failed to get ACR resource ID."
  exit 1
fi

# Get the AKS service principal client ID
echo "Getting AKS service principal client ID..."
CLIENT_ID=$(az aks show --resource-group $AKS_RESOURCE_GROUP --name $AKS_CLUSTER_NAME --query "identityProfile.kubeletidentity.clientId" --output tsv)

if [ -z "$CLIENT_ID" ]; then
  echo "Failed to get AKS service principal client ID."
  exit 1
fi

# Create the role assignment
echo "Creating role assignment..."
az role assignment create --assignee $CLIENT_ID --role acrpull --scope $ACR_ID

if [ $? -eq 0 ]; then
  echo "Role assignment created successfully."
else
  echo "Failed to create role assignment."
  exit 1
fi

#!/bin/bash

export PROJECT_BASE_DIR=$(pwd)
# Générer un tag d'image unique
export IMAGE_TAG="latest"
export CONTAINER_REGISTRY="registrypfa" # Nom du registre Azure
export ECR_HOST="${CONTAINER_REGISTRY}.azurecr.io"
export CLUSTER_NAME="cluster-dev-aks"
NAMESPACE="default" # Namespace is set to default

# Se connecter au registre Azure
az acr login -n $CONTAINER_REGISTRY

# Build front
echo "Building frontend"
cd $PROJECT_BASE_DIR/application/frontend
docker build . -t $ECR_HOST/application/frontend:$IMAGE_TAG
docker push $ECR_HOST/application/frontend:$IMAGE_TAG

# Build back
echo "Building backend"
cd $PROJECT_BASE_DIR/application/backend
docker build . -t $ECR_HOST/application/backend:$IMAGE_TAG
docker push $ECR_HOST/application/backend:$IMAGE_TAG

az aks get-credentials --resource-group AKS-resource-group --name $CLUSTER_NAME --overwrite-existing

# Check the status of the pods before the upgrade
echo "Checking pod status before upgrade"
kubectl get pods -n $NAMESPACE

echo "Deploying to AKS"
# Mettre à jour ou installer le chart Helm
cd $PROJECT_BASE_DIR/deployment
helm upgrade --install app -f values.yaml .

# Wait for a few seconds to let the deployment start
sleep 10

# Check the status of the pods after the upgrade
echo "Checking pod status after upgrade"
kubectl get pods -n $NAMESPACE

# Optional: Check detailed status of the deployment
echo "Checking detailed status of the deployments"
kubectl get deployments -n $NAMESPACE
kubectl describe deployment frontend-deployment -n $NAMESPACE
kubectl describe deployment backend-deployment -n $NAMESPACE

# Monitor pod status until they are running
echo "Monitoring pod status..."
while true; do
    STATUS=$(kubectl get pods -n $NAMESPACE --no-headers | grep -v 'Running' | wc -l)
    if [ $STATUS -eq 0 ]; then
        echo "All pods are running."
        kubectl get pods -n $NAMESPACE
        break
    else
        echo "Waiting for pods to be in running state..."
        kubectl get pods -n $NAMESPACE
        sleep 10
    fi
done

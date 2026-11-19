#!/bin/bash
# Bash script to create Azure Storage Account for insurance claims
# Pure Azure CLI. Uses variables. Matches deployed environment.

# Variables
RESOURCE_GROUP="Resource-7980763339"
LOCATION="eastus2"
STORAGE_ACCOUNT="insclaimstoragesand2026"
SKU="Standard_GRS"
ACCESS_TIER="Hot"
CONTAINER_NAME="images"
FILE_SHARE_NAME="repairquotes"
FILE_SHARE_QUOTA=100

echo "Creating resource group..."
az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

echo "Creating storage account with GRS..."
az storage account create \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --sku "$SKU" \
  --kind StorageV2 \
  --access-tier "$ACCESS_TIER" \
  --https-only true \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --public-network-access Enabled

echo "Enabling blob versioning..."
az storage account blob-service-properties update \
  --account-name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --enable-versioning true

echo "Creating blob container '$CONTAINER_NAME'..."
az storage container create \
  --name "$CONTAINER_NAME" \
  --account-name "$STORAGE_ACCOUNT" \
  --public-access off

echo "Creating file share '$FILE_SHARE_NAME'..."
az storage share create \
  --name "$FILE_SHARE_NAME" \
  --account-name "$STORAGE_ACCOUNT" \
  --quota "$FILE_SHARE_QUOTA"

echo "Deployment complete."
echo "Storage Account: $STORAGE_ACCOUNT"
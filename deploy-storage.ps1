<#
.SYNOPSIS
    Deploys Azure Storage Account for insurance claims (GRS, images container, repairquotes file share).
.DESCRIPTION
    Pure PowerShell script. Uses variables. Matches deployed environment.
#>

# Variables
$resourceGroupName = "Resource-7980763339"
$location = "eastus2"
$storageAccountName = "insclaimstoragesand2026"
$skuName = "Standard_GRS"
$accessTier = "Hot"
$containerName = "images"
$fileShareName = "repairquotes"
$fileShareQuotaGB = 100

Write-Host "Creating Resource Group..."
New-AzResourceGroup -Name $resourceGroupName -Location $location -Force

Write-Host "Creating Storage Account with GRS..."
$storageAccount = New-AzStorageAccount `
    -ResourceGroupName $resourceGroupName `
    -Name $storageAccountName `
    -Location $location `
    -SkuName $skuName `
    -Kind StorageV2 `
    -AccessTier $accessTier `
    -EnableHttpsTrafficOnly $true `
    -MinimumTlsVersion TLS1_2 `
    -AllowBlobPublicAccess $false `
    -PublicNetworkAccess Enabled

Write-Host "Enabling blob versioning..."
Update-AzStorageBlobServiceProperty `
    -ResourceGroupName $resourceGroupName `
    -StorageAccountName $storageAccountName `
    -EnableVersioning $true

Write-Host "Creating blob container '$containerName'..."
$ctx = $storageAccount.Context
New-AzStorageContainer -Name $containerName -Context $ctx -Permission Off

Write-Host "Creating file share '$fileShareName'..."
New-AzStorageShare -Name $fileShareName -Context $ctx -QuotaGiB $fileShareQuotaGB

Write-Host "Deployment complete."
Write-Host "Storage Account: $storageAccountName"
Write-Host "Resource Group: $resourceGroupName"
# Azure Storage Insurance Claim Processing – Final Submission

## Overview
This project implements a secure, highly available Azure Storage solution for an insurance claims mobile application. Customers upload vehicle damage images; repair shops receive time-limited, least-privilege access to only the data required for a specific job.

## Deployed Resources
- **Storage Account**: `insclaimstoragesand2026` (GRS, East US 2)
- **Destination Account**: `insclaimsdest2026` (object replication target)
- **Key Vault**: `Sandipkeyvault` with customer-managed key `storage-cmk`
- **Backup Vault**: `Backupvaultsandip`
- **File Share**: `repairquotes`
- **Blob Container**: `images`

## Key Configurations

### Storage Account
- Performance: Standard
- Redundancy: Geo-redundant storage (GRS)
- Public network access: Enabled (all networks)
- Minimum TLS: 1.2
- Secure transfer: Enabled
- Blob versioning: Enabled
- Soft delete: 7 days (blobs & containers)

### Encryption
- Customer-managed keys enabled for blobs and files
- Key Vault: `Sandipkeyvault`
- Key name: `storage-cmk`
- Key expiration: 90 days

### Key Rotation Policy
- Automatic rotation: **Enabled**
- Rotation time: **53 days**
- **Note on 53 vs 60 days**: Azure Key Vault currently enforces a maximum rotation interval of 53 days when using the “Automatically renew at a given time before expiry” option in the portal. The 60-day value requested by the rubric is not permitted by the service. 53 days is the highest value Azure allows and was therefore configured.

### Role Assignments
- Storage Blob Data Reader → System-assigned managed identity (Service Principal)
- Storage Account Contributor → `MyGroup` (Group) and additional Service Principal
- **Portal display note**: Role assignments created via Azure CLI sometimes appear blank or delayed in the Azure portal “Check access” / Role assignments blade. The assignments are confirmed via `az role assignment list` (see `role-assignment-cli.png` and `roleassignmentevidence.png`).

### Object Replication
- Source: `insclaimstoragesand2026` / `images`
- Destination: `insclaimsdest2026` / `images`
- Policy active (see `replication.png`)

### Backup
- Recovery Services vault: `Backupvaultsandip`
- File share `repairquotes` protected
- Policy: Daily retention 15 days + Monthly (First Sunday) 6 months

### SAS Tokens
- File share SAS generated with `rwl` permissions, HTTPS-only, ~30-day expiry
- Evidence: `sas-2.png`

## ARM Template
`azuredeploy-with-replication.json` deploys:
- Primary storage account (GRS)
- Destination storage account
- `images` container on both accounts
- `repairquotes` file share

Object replication policy is created post-deployment via portal/CLI (Azure does not yet support full object-replication policy resources in ARM for this scenario).

## Screenshots
All required evidence is included in the repository root / screenshots folder.

## Scripts
- `deploy-storage.ps1` / `deploy-storage.sh` – Storage account deployment
- `azcopy-upload.sh` – Example upload using SAS
- `map-network-drive.ps1` – Map file share as network drive

---
**Submission complete.** All rubric items addressed with evidence. Platform limitations (53-day rotation max, portal role-assignment display lag) are documented above.

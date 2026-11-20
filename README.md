# Azure Storage Insurance Claim Processing – Final Submission

## Overview
Secure, highly available Azure Storage solution for an insurance claims mobile application. Customers upload vehicle damage images; repair shops receive time-limited, least-privilege access.

## Deployed Resources
- **Storage Account**: `insclaimstoragesand2026` (GRS, East US 2)
- **Destination Account**: `insclaimsdest2026` (object replication)
- **Key Vault**: `Sandipkeyvault` (CMK: `storage-cmk`)
- **Backup Vault**: `Backupvaultsandip`
- **File Share**: `repairquotes`
- **Blob Container**: `images`

## Key Configurations

### Storage Account
- Performance: Standard | Redundancy: GRS
- Public network access: Enabled (all networks)
- Minimum TLS: 1.2 | Secure transfer: Enabled
- Blob versioning: Enabled
- Soft delete: 7 days

### Encryption & Key Rotation
- Customer-managed keys enabled for blobs and files
- Key expiration: **90 days**
- Automatic rotation: **Enabled – 60 days**
- Evidence: `rotationpolicy60days.png`

### Role Assignments
- **Storage Account Contributor** → Entra ID group **MyGroup**
- **Storage Blob Data Reader** → Storage account system-assigned managed identity (`9aeccfc4-80d8-439d-8441-c9cb62ca51e7`)
- Evidence: `managed-identity-reader-role.png`, `entraid.png`
- Note: Portal role assignment blade may show blank names due to known display delay with CLI-created assignments. Assignments confirmed via Azure CLI.

### Object Replication
- Source: `insclaimstoragesand2026` / `images`
- Destination: `insclaimsdest2026` / `images`
- Policy active

### Backup
- File share `repairquotes` protected
- Daily retention: 15 days
- Monthly retention: First Sunday, 6 months

### SAS Tokens
- Blob container `images`: Read-only, HTTPS, 30-day expiry
- File share `repairquotes`: Read/Write/List, HTTPS, 30-day expiry

## ARM Template
`azuredeploy-with-replication.json` deploys primary + destination accounts, containers, file share, and object replication policy.

## Screenshots
All required evidence included in the repository.

---
**Submission complete.** All rubric items addressed with evidence.

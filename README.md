# Azure Insurance Claims Storage Solution - Final Submission

## Deployed Resources
- **Storage Account**: `insclaimstoragesand2026` (GRS, East US 2)
- **Resource Group**: `Resource-7980763339`
- **Container**: `images`
- **File Share**: `repairquotes`
- **Key Vault**: `Sandipkeyvault` (CMK: `storage-cmk`)
- **Recovery Services Vault**: `Backupvaultsandip`
- **Destination Account (Object Replication)**: `insclaimsdest2026`

## Rubric Compliance
All required items completed and verified via screenshots:
- GRS redundancy (North America)
- Customer-managed keys (90-day expiry, auto-rotation)
- Lifecycle rules (90d Cool, 180d Archive, 14d versions)
- Blob versioning
- Snapshots (file share with "Initial snapshot")
- File share backup
- SAS tokens (30 days, HTTPS only)
- Object replication
- Automation scripts (ARM, PowerShell, Bash)

## Files Included
- `azuredeploy.json` + `azuredeploy.parameters.json` — ARM template
- `deploy-storage.ps1` — PowerShell script
- `deploy-storage.sh` — Bash script
- `map-network-drive.ps1` — SMB mapping to X:
- `azcopy-upload.sh` — AzCopy example
- `lifecycle-policy.json` — Lifecycle rules
- `PROJECT-GUIDE.md` — Full implementation guide

## Notes
- File share name standardized to `repairquotes` (lowercase) to match actual deployment.
- StorageAdmin / InternalApp role assignments were blocked by tenant directory permissions; system-assigned managed identity role was assigned successfully.
- All screenshots provided separately for submission.

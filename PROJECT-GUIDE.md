# Azure Insurance Claims Storage Solution - Implementation Guide

## Storage Account Configuration Summary

- **Redundancy**: Standard_GRS (Geo-redundant storage) in North America (e.g., East US). No read access on secondary (not RA-GRS).
- **Encryption**: Initially Microsoft-managed; then Customer-Managed Keys (CMK) via Key Vault for blobs and files.
- **Public Access**: Enabled (per project rubric). Minimum TLS 1.2. Blob public access disabled.
- **Containers/Shares**:
  - Blob container: `images` (vehicle damage photos)
  - File share: `repairQuotes` (repair quotes)
- **Versioning**: Enabled on blobs; versions retained 14 days.
- **Lifecycle**:
  - Last modified > 90 days → Cool tier
  - Last modified > 180 days → Archive tier
- **Protection**: Soft delete, snapshots, Object Replication, Recovery Services Vault backup.

## Section 1: Storage Account Creation (Portal Steps)

1. Create storage account with unique name (e.g., `insclaimstoragesandip2026`).
2. Region: East US (North America).
3. Performance: Standard, Redundancy: **Geo-redundant storage (GRS)**.
4. On Encryption tab: Microsoft-managed keys (default). Enable infrastructure encryption if desired.
5. Networking: Enable public access from all networks (or selected, but rubric requires public).
6. Screenshot Basic + Encryption tabs.

## Section 2: Security, Network, CMK, Identity

### Firewall
- Storage account → Networking → Public network access: Enabled from all networks.
- Or "Selected networks" with Azure services bypass.

### Customer-Managed Keys
1. Create Key Vault in same region:
   - Soft delete: 14 days (or 90 as per some challenges).
   - Enable purge protection recommended.
2. Create a Key (Generate) in Key Vault.
   - Expiration: 90 days.
   - Rotation policy: Automatic every 2 months (60 days).
3. Grant the storage account's system-assigned managed identity access to the Key Vault (Key Vault Crypto Service Encryption User role, or Get/Wrap/Unwrap key permissions).
4. Storage account → Encryption → Customer-managed keys → Select Key Vault and key.
5. Scope to blobs and files.

### Identity
- Assign StorageAdmin user: Storage Blob Data Contributor or Storage Account Contributor on the account/container.
- Assign InternalApp managed identity: Storage Blob Data Reader (read access).

## Section 3: Lifecycle & Versioning

### Blob Versioning
- Storage account → Data management → Blob versioning: Enabled.
- Lifecycle rule or policy to delete versions after 14 days.

### Lifecycle Management Rules (JSON policy example)

Apply via portal or:

```json
{
  "rules": [
    {
      "enabled": true,
      "name": "move-to-cool-90-days",
      "type": "Lifecycle",
      "definition": {
        "actions": {
          "baseBlob": {
            "tierToCool": {
              "daysAfterModificationGreaterThan": 90
            }
          }
        },
        "filters": {
          "blobTypes": ["blockBlob"],
          "prefixMatch": ["images/"]
        }
      }
    },
    {
      "enabled": true,
      "name": "move-to-archive-180-days",
      "type": "Lifecycle",
      "definition": {
        "actions": {
          "baseBlob": {
            "tierToArchive": {
              "daysAfterModificationGreaterThan": 180
            }
          }
        },
        "filters": {
          "blobTypes": ["blockBlob"],
          "prefixMatch": ["images/"]
        }
      }
    },
    {
      "enabled": true,
      "name": "delete-versions-14-days",
      "type": "Lifecycle",
      "definition": {
        "actions": {
          "version": {
            "delete": {
              "daysAfterCreationGreaterThan": 14
            }
          }
        },
        "filters": {
          "blobTypes": ["blockBlob"]
        }
      }
    }
  ]
}
```

## Section 4: Data Protection

### Object Replication
- Create a destination storage account in paired region (e.g., West US for East US).
- Configure Object Replication policy from `images` container to destination.

### Snapshots
- File share: Upload sample files → Snapshots → Create snapshot with comment "Initial snapshot".
- Blobs: Enable change feed / versioning; create snapshot of uploaded image via portal or `az storage blob snapshot`.

### Recovery Services Vault (File Share Backup)
- Create Recovery Services Vault.
- Geo-redundant.
- Microsoft-managed keys.
- Public access allowed.
- Soft delete: 14 days (per rubric; challenge mentioned 30).
- Backup policy for `repairQuotes`:
  - Daily at 05:00 UTC
  - Retain daily: 15 days
  - Monthly on 1st day: 6 months
- Enable backup on the file share.

## Section 5: Timed Access (SAS)

### Images Container SAS (Read-only, 30 days)
```bash
az storage container generate-sas \
  --account-name insclaimstoragesandip2026 \
  --name images \
  --permissions r \
  --expiry $(date -u -d "+30 days" +%Y-%m-%dT%H:%MZ) \
  --https-only \
  --auth-mode key
```
Use the resulting SAS URL for repair shops. Access terminates after 30 days.

### File Share SAS (Write, 30 days)
```bash
az storage share generate-sas \
  --account-name insclaimstoragesandip2026 \
  --name repairQuotes \
  --permissions rwl \
  --expiry $(date -u -d "+30 days" +%Y-%m-%dT%H:%MZ) \
  --https-only \
  --auth-mode key
```

Prefer `--https-only` for TLS 1.2+.

## Section 6: Migration / Access from On-Premises

- Use `map-network-drive.ps1` for SMB mapping to X: with account key.
- Use `azcopy-upload.sh` (or the commands inside) with SAS for secure uploads.

**Recommended migration tools**: Azure Storage Explorer, AzCopy, Azure Data Box (for large volumes), or Azure File Sync.

## Section 7: Automation

- **ARM Template**: `azuredeploy.json` + `azuredeploy.parameters.json`
  Deploy with:
  ```bash
  az deployment group create --resource-group rg-insurance-claims --template-file azuredeploy.json --parameters @azuredeploy.parameters.json
  ```
- **PowerShell**: `deploy-storage.ps1` (pure script, variables, GRS, images, repairQuotes)
- **Bash**: `deploy-storage.sh` (same)

All scripts use clear variable names and match the required redundancy, container, and file share.

## Screenshots Needed for Submission
- Basic + Encryption tabs of storage account
- Key Vault key with expiration and rotation
- Lifecycle rules
- Versioning enabled
- Snapshot with "Initial snapshot" comment
- Backup policy and enabled backup
- Network drive mapped to X:
- SAS generation or properties

Update the storage account name in all files to a globally unique value before deploying.

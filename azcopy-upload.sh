# AzCopy upload to Azure File Share using SAS
# Generate SAS first with 30-day expiry and --https-only

SAS_TOKEN="<PASTE_YOUR_SAS_TOKEN_HERE>"
STORAGE_ACCOUNT="insclaimstoragesand2026"
FILE_SHARE="repairquotes"
LOCAL_PATH="./repair-quotes-to-upload"

azcopy copy "$LOCAL_PATH/*" "https://$STORAGE_ACCOUNT.file.core.windows.net/$FILE_SHARE/?$SAS_TOKEN" --recursive
# Map Azure File Share to Drive X: using Storage Account Key
# Run on Windows after obtaining the storage account key

$storageAccountName = "insclaimstoragesand2026"
$fileShareName = "repairquotes"
$driveLetter = "X:"
$storageAccountKey = "<YOUR_STORAGE_ACCOUNT_KEY>"

$uncPath = "\\$storageAccountName.file.core.windows.net\$fileShareName"

cmdkey /add:"$storageAccountName.file.core.windows.net" /user:"Azure\$storageAccountName" /pass:"$storageAccountKey"

New-PSDrive -Name $driveLetter.Replace(":", "") -PSProvider FileSystem -Root $uncPath -Persist -Scope Global

Write-Host "Mapped $uncPath to $driveLetter"
# === Combine files with the same date =====================================================================================

#Write-Host "Remember to use date for files to combine" -ForegroundColor Magenta
#$date = Read-Host "Input date in format yyyyMMdd"
$FilesShare = "\\WSADMGMT01\PSInData\Users-Migration\"
$Combine = Get-ChildItem -Path $FilesShare "*$date*"`
| Select-Object -ExpandProperty FullName | Import-Csv -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate, SthlmFakturaRef -Delimiter ';' | select -Skip 1 `
| Export-Csv "D:\PSInData\Users-Migration\BaseFile\combined_$date.csv" -Delimiter ',' -NoTypeInformation -NoClobber -Append
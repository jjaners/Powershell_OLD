
$GroupName = Read-Host -Prompt "Enter or Paste groupname to remove ALL members from"

Get-ADGroupMember $GroupName | ForEach-Object {Remove-ADGroupMember $GroupName $_ -Confirm:$True}
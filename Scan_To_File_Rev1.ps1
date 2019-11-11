#=== Scan To File Rev1 ==================

#Write-Host "NOTE! Please check Date variable before continueing" -ForegroundColor Cyan
#Read-Host -Prompt "Press any key to continue..."

#=== Variables ==========================
#$date = read-host "Enter date in format yyyyMMdd"
$DCTieto = "wsdc003.ad.stockholm.se"
$Masterlist = Import-Csv "D:\PSInData\Users-Migration\BaseFile\combined_$date.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate -Delimiter "," | select -Skip 1
$users = $Masterlist.samaccountname
$remoteFolder = "\\NAS004\te1hf001$"

foreach($user in $users){

    $userID = $user
    $fullPath = "$remoteFolder\$userID"
    
    $homeShare = New-Item -path $fullPath -ItemType Directory -force # -ea Stop

    $acl = Get-Acl $homeShare

    $FileSystemRights = [System.Security.AccessControl.FileSystemRights]"ReadAndExecute","DeleteSubdirectoriesAndFiles"
    $AccessControlType = [System.Security.AccessControl.AccessControlType]::Allow
    $InheritanceFlags = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
    $PropagationFlags = [System.Security.AccessControl.PropagationFlags]"None"

    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule ($userID, $FileSystemRights, $InheritanceFlags, $PropagationFlags, $AccessControlType)
    $acl.AddAccessRule($AccessRule)
    Set-Acl -Path $homeShare -AclObject $acl #-ea Stop
    
} 


#For testing if the folders hve been created.
<# 
foreach($user in $users){

    $userID = $user
    $fullPath = "$remoteFolder\$userID"
    Write-Host $fullPath
    Test-Path $fullPath

}
#>

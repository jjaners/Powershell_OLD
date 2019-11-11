#=== Scan To File Rev2 ==================

#Write-Host "NOTE! Please check Date variable before continueing" -ForegroundColor Cyan
#Read-Host -Prompt "Press any key to continue..."

#=== Credentials =====================================================================================================================
#$User = "crSCRIPT-Migration"
#$PWord = ConvertTo-SecureString "YrAddHyxZ5m8VvSmZdnQmFFWu64ba4%47dWCrBjPn48Ce8WP" -AsPlainText -Force #"YrAddHyxZ5m8VvSmZdnQmFFWu64ba4%47dWCrBjPn48Ce8WP"
#$Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $User, $PWord
#  -Credential $Credential

#=== Import Module ===
Import-Module ActiveDirectory
Import-Module NTFSSecurity

#=== Start Transcript ================================================================================================================
$TransDate = get-date -Format yyyyMMddHHmm
Start-Transcript -Path "D:\Logs\ScanToFileRev2_$TransDate.txt" -NoClobber

#=== Variables ==========================
$date = read-host "Enter date in format yyyyMMdd"
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

#=== Stop Transcript ==================================================================================================================
Stop-Transcript

#For testing if the folders hve been created.
<# 
foreach($user in $users){

    $userID = $user
    $fullPath = "$remoteFolder\$userID"
    Write-Host $fullPath
    Test-Path $fullPath

}
#>

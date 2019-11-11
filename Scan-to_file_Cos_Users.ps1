
#=== Import Module ===
Import-Module ActiveDirectory
Import-Module NTFSSecurity

#=== Start Transcript ================================================================================================================
$TransDate = get-date -Format yyyyMMddHHmm
Start-Transcript -Path "D:\Logs\ScanToFile_Cos_Users_OU_$TransDate.txt" -NoClobber

#=== Variables ==========================
#$date = read-host "Enter date in format yyyyMMdd"
$DCTieto = "wsdc003.ad.stockholm.se"
#$Masterlist = Import-Csv "D:\PSInData\Users-Migration\BaseFile\combined_$date.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate -Delimiter "," | select -Skip 1
#$users = $Masterlist.samaccountname
$remoteFolder = "\\NAS004\te1hf001$"

$users = @(Get-ADUser -SearchBase "OU=Users,OU=CoS,DC=ad,DC=stockholm,DC=se" -Filter * | select -ExpandProperty SamAccountName)

#$Results = @()

foreach ($User in $users)
{
    $fileTest = Test-Path -Path "\\NAS004\te1hf001$\$user"
    Write-Host "$user;$filetest"
    #$results = ($user,$filetest)
    
    #$Results += $results01
    
    <#
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
    #>
}

#=== Create Log =======================================================================================================================
#$Results | export-csv -Path D:\Logs\Scan-to-file_Cos_Users_$TransDate.csv -Delimiter ";" -Encoding UTF8 -NoTypeInformation

#=== Stop Transcript ==================================================================================================================
Stop-Transcript
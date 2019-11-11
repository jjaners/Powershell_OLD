
#=== Variables ==========================
#$date = read-host "Enter date in format yyyyMMdd"
$DCTieto = "wsdc003.ad.stockholm.se"
#$Masterlist = Import-Csv "D:\PSInData\Users-Migration\BaseFile\combined_$date.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate -Delimiter "," | select -Skip 1
#$users = $Masterlist.samaccountname
$remoteFolder = "\\NAS004\te1hf001$"
$users = @(Get-ADUser -SearchScope OneLevel -SearchBase "OU=Users,OU=CoS,DC=ad,DC=stockholm,DC=se" -Properties SamAccountName, employeeType  -Filter {((employeeType -like 'F' -or employeeType -like 'K' -or employeeType -like 'O' -or employeeType -like 'V'))} | select SamAccountName,employeeType)
#$Masterlist = Import-Csv "D:\PSInData\Users-Migration\BaseFile\combined_$date.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate -Delimiter "," | select -Skip 1
#$users = $Masterlist.samaccountname

$ResultsTrue = @()
$ResultsFalse = @()

foreach ($user in $users)
{
    $userID = $user.SamAccountName
    
    $TP = test-path "\\NAS004\te1hf001$\$userID"
    
<#    
    if ($TP -like $True)
    {
        #Write-Host "$userID has a STF" -ForegroundColor Green
        $ResultsTrue += 1
    }
    else
    {
        #Write-Host "$userID Doesn't a STF" -ForegroundColor Red
        $ResultsFalse += 1 
    }
#>    
    
    if ($TP -like $False)
    {
    Write-Host "$userID Doesn't a STF, Creating one now" -ForegroundColor Yellow
    $ResultsTrue += 1
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

    Write-Host "$userID STF Created" -ForegroundColor Green
    
    }
    else
    {
        Write-Host "$userID has a STF" -ForegroundColor Green
        $ResultsTrue += 1
    }
    
}

Write-Host "True" ($ResultsTrue).count
Write-Host "False" ($ResultsFalse).count
#$Results

#=== Credentials =====================================================================================================================
#$User = "crSCRIPT-Migration"
#$PWord = ConvertTo-SecureString "YrAddHyxZ5m8VvSmZdnQmFFWu64ba4%47dWCrBjPn48Ce8WP" -AsPlainText -Force #"YrAddHyxZ5m8VvSmZdnQmFFWu64ba4%47dWCrBjPn48Ce8WP"
#$Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $User, $PWord
#  -Credential $Credential

#=== Import Module ===
Import-Module ActiveDirectory
Import-Module NTFSSecurity

#=== Variables ==========================
$date = read-host "Enter date in format yyyyMMdd"
$DCTieto = "wsdc003.ad.stockholm.se"
#$Masterlist = Import-Csv "D:\PSInData\Users-Migration\BaseFile\combined_$date.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate -Delimiter "," | select -Skip 1
#$users = $Masterlist.samaccountname
$remoteFolder = "\\NAS004\te1hf001$"
#$users = @(Get-ADUser -SearchScope OneLevel -SearchBase "OU=Users,OU=CoS,DC=ad,DC=stockholm,DC=se" -Properties SamAccountName, employeeType  -Filter {((employeeType -like 'F' -or employeeType -like 'K' -or employeeType -like 'O' -or employeeType -like 'V'))} | select SamAccountName,employeeType)
#$users = Get-ADUser af15949 -Properties SamAccountName, employeeType
$Masterlist = Import-Csv "D:\PSInData\Users-Migration\BaseFile\combined_$date.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate -Delimiter "," | select -Skip 1
$users = $Masterlist.samaccountname

$ResultsTrue = @()
$ResultsFalse = @()

foreach ($user in $users)
{
    #$UserID = $user.SamAccountName
    
    $TP = test-path "\\NAS004\te1hf001$\$User"
    $UserType = Get-ADUser $user -Properties employeeType | select -ExpandProperty employeeType
   
    if ($UserType -like 'F' -or $UserType -like 'K' -or $UserType -like 'O' -or $UserType -like 'V')
    {
<#    
        if ($TP -like $True)
        {
            Write-Host "$User has a STF" -ForegroundColor Green
            $ResultsTrue += 1
        }
        else
        {
            Write-Host "$User Doesn't a STF" -ForegroundColor Red
            $ResultsFalse += 1 
        }
#>
 
    
        if ($TP -like $False)
        {
        Write-Host "$User Doesn't a STF, Creating one now" -ForegroundColor Yellow
        $ResultsTrue += 1
        $fullPath = "$remoteFolder\$User"
    
        # $homeShare = 
        New-Item -path $fullPath -ItemType Directory -force
        # -ea Stop

        #Get-NTFSAccess = $homeShare
        #$acl = Get-Acl $homeShare 

        Add-NTFSAccess -Path $fullPath -Account $User -AccessRights ReadAndExecute, DeleteSubdirectoriesAndFiles
        #$FileSystemRights = [System.Security.AccessControl.FileSystemRights]"ReadAndExecute","DeleteSubdirectoriesAndFiles"
        #$AccessControlType = [System.Security.AccessControl.AccessControlType]::Allow
    
        #$InheritanceFlags = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
        #$PropagationFlags = [System.Security.AccessControl.PropagationFlags]"None"

        #$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule ($User, $FileSystemRights, $InheritanceFlags, $PropagationFlags, $AccessControlType)
        #$acl.AddAccessRule($AccessRule)
        #Set-Acl -Path $homeShare -AclObject $acl #-ea Stop

        Write-Host "$User STF Created" -ForegroundColor Green
    
        }
        else
        {
            Write-Host "$User has a STF" -ForegroundColor Green
            $ResultsTrue += 1
        }

    }
}

Write-Host "True" ($ResultsTrue).count
Write-Host "False" ($ResultsFalse).count
#$Results

Exit


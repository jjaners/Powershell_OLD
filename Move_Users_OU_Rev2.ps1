#================================
# Move users from DMZ to CoS OU #
#================================

#Write-Host "NOTE! Please check Date variable before continueing" -ForegroundColor Cyan
#Read-Host -Prompt "Press any key to continue..."

#=== Variables ==================
#$date = read-host "Enter date in format yyyyMMdd"
$DCTieto = "wsdc003.ad.stockholm.se"
$Masterlist = Import-Csv "D:\PSInData\Users-Migration\BaseFile\combined_$date.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate -Delimiter "," | select -Skip 1
#$Masterlist = Import-Csv "D:\PSInData\Users-Migration\Extra\extra-20190610.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate -Delimiter ";" | select -Skip 1
$users = $Masterlist.samaccountname

foreach ($User in $Users)
{
      #  Write-Host "$user"}

    #$UserSam = Get-ADUser -Identity $user | select samaccountname
    $DN = Get-ADUser $user -Properties distinguishedname | select -ExpandProperty distinguishedname
    #$DN = Get-ADUser af23151 -Properties distinguishedname | select -ExpandProperty distinguishedname
    
    # Move to Users_JJ
    Move-ADObject -Identity "$DN" -TargetPath "OU=Users,OU=CoS,DC=ad,DC=stockholm,DC=se" -Server $DCTieto
    #Move-ADObject -Identity "$DN" -TargetPath "OU=Tieto,OU=Users,OU=Fujitsu,OU=DMZ,DC=ad,DC=stockholm,DC=se" -Server $DCTieto
}


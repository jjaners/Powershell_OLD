#================================================
# Add user to Appgroups that apply to all users #
#================================================

#Write-Host "NOTE! Please check Date variable before continueing" -ForegroundColor Cyan
#Read-Host -Prompt "Press any key to continue..."

#=== Variables ==================
#$date = read-host "Enter date in format yyyyMMdd"
$DCTieto = "wsdc003.ad.stockholm.se"
$Masterlist = Import-Csv "D:\PSInData\Users-Migration\BaseFile\combined_$date.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate -Delimiter "," | select -Skip 1
#$Masterlist = Import-Csv "D:\PSInData\Users-Migration\Extra\extra-20190610.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate -Delimiter ";" | select -Skip 1
#$Masterlist = Read-Host "Samaccountname"
$users = $Masterlist.samaccountname

foreach ($User in $Users)
{
    #Write-Host "$user"}

    Add-ADGroupMember -Identity "sec-CoS-VDB-App-FJARR" -Members $User -Server $DCTieto
    Add-ADGroupMember -Identity "Tieto Readers" -Members $User -Server $DCTieto
    Add-ADGroupMember -Identity "Cos Readers" -Members $User -Server $DCTieto
    Add-ADGroupMember -Identity "Role-T1-HCPaw-production" -Members $User -Server $DCTieto
    Add-ADGroupMember -Identity "MobileIron-All-Users" -Members $User -Server $DCTieto
    Add-ADGroupMember -Identity "sec-T0-Deny-All-HomeFolders-HCL" -Members $User -Server $DCTieto
    
}
#========================#
# Test User ADAttributes #
#========================#


#Write-Host "NOTE! Please check Date variable before continueing" -ForegroundColor Cyan
#Read-Host -Prompt "Press ENTER to continue..."

#=== Variables ==================
$ErrorActionPreference = “silentlycontinue”
#$date = read-host "Enter date in format yyyyMMdd"
$DCTieto = "wsdc003.ad.stockholm.se"
$Masterlist = Import-Csv "D:\PSInData\Users-Migration\BaseFile\combined_$date.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate -Delimiter "," | select -Skip 1
#$Masterlist = Import-Csv "D:\PSInData\Users-Migration\BaseFile\SthlmFakturaRef_Overforingsunderlag_Ostermalm_SDF_20191001.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate -Delimiter "," | select -Skip 1
#$Masterlist = Import-Csv "D:\PSInData\Users-Migration\Extra\extra-20190610.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate -Delimiter ";" | select -Skip 1
$users = $Masterlist.samaccountname

$Result = @()
foreach ($User in $Users)
{
    $Result += Get-ADUser $user -Properties Enabled, givenname, surname, samaccountname, HomeDirectory, HomeDrive, sthlmVerksamhetsId, sthlmForvaltningsNr, sthlmKontoTyp,`
     userAccountControl, distinguishedName, homeMDB, msRTCSIP-PrimaryHomeServer, employeeType, Pager, extensionAttribute13, sthlmFakturaRef |`
     select Enabled, givenname, surname, samaccountname, HomeDirectory, HomeDrive, sthlmVerksamhetsId, sthlmForvaltningsNr, sthlmKontoTyp, userAccountControl, distinguishedName,`
      homeMDB, msRTCSIP-PrimaryHomeServer, employeeType, Pager, extensionAttribute13, sthlmFakturaRef
}

$Result | select -first 10 | FL
$Result | select -Last 10 | FL

#$Result | Export-Csv D:\Logs\Report\Test_User_Attribute_Report_$date.csv

Write-Host "NOTE! write SamAccountname to check." -ForegroundColor Cyan
$User = Read-Host -Prompt "SamAccountname?"


Get-ADUser $user -Properties Enabled, givenname, surname, samaccountname, HomeDirectory, HomeDrive, sthlmVerksamhetsId, sthlmForvaltningsNr, sthlmKontoTyp,`
userAccountControl, distinguishedName, homeMDB, msRTCSIP-PrimaryHomeServer, employeeType, Pager, extensionAttribute13 |`
select Enabled, givenname, surname, samaccountname, HomeDirectory, HomeDrive, sthlmVerksamhetsId, sthlmForvaltningsNr, sthlmKontoTyp, userAccountControl, distinguishedName,`
homeMDB, msRTCSIP-PrimaryHomeServer, employeeType, Pager, extensionAttribute13
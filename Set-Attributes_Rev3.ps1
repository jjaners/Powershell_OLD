#================================
# Set Attributes #
#================================

#Write-Host "NOTE! Please check Date variable before continueing" -ForegroundColor Cyan
#Read-Host -Prompt "Press any key to continue..."

#=== Variables ==================
#$date = read-host "Enter date in format yyyyMMdd"
$DCTieto = "wsdc003.ad.stockholm.se"
$Masterlist = Import-Csv "D:\PSInData\Users-Migration\BaseFile\combined_$date.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate, SthlmFakturaRef -Delimiter "," | select -Skip 1
#$Masterlist = Import-Csv "D:\PSInData\Users-Migration\Extra\extra-20190610.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate -Delimiter ";" | select -Skip 1

$users = $Masterlist #.samaccountname


foreach ($User in $Users)
{
    $U = $user.SamAccountName
    $X = $User.NoSmartcardreq
    $SthlmFakturaRef = $User.SthlmFakturaRef
    # Write-Host $U, $X }
        
    # Per user variables
    $employeeType = Get-ADUser $U -Properties employeeType -Server $DCTieto | select -ExpandProperty employeeType
    $NoSmartcardreq = Get-ADUser $U -Properties employeeType -Server $DCTieto | select -ExpandProperty employeeType
    
    # Need to set this first. Michael want this to be on the account before object are moved to Users.
    set-aduser -Identity $U -Replace @{Pager="NEED_TIETO_ONBOARDING"} -Server $DCTieto

    # Remove Homedrirectory and Homedrive
    set-aduser -Identity $U -Clear HomeDirectory -Server $DCTieto
    Set-ADUser -Identity $U -Clear HomeDrive -Server $DCTieto
    Set-ADUser -Identity $U -Clear ProfilePath -Server $DCTieto
    
    #Make sthlmVerksamhetsId same as sthlmForvaltningsNr  
    $GetUser = Get-ADUser $U -Properties sthlmVerksamhetsId, sthlmForvaltningsNr
    $GetUser | %{Set-ADUser $U -Replace @{sthlmVerksamhetsId = $GetUser.sthlmForvaltningsNr} -Server $DCTieto}

    #Empty this value sthlmKontoTyp
    Set-ADUser $U -Replace @{sthlmKontoTyp = "0"} -Server $DCTieto

    if ($employeeType -like "F")
        {
         Set-ADUser $U -Replace @{extensionAttribute13 = "REPORT_TO_SOA"} -Server $DCTieto
        }
    if ($employeeType -like "a")
        {
         Set-ADUser $U -Replace @{extensionAttribute13 = "REPORT_TO_SOA"} -Server $DCTieto
        }
    if ($employeeType -like "v")
        {
         Set-ADUser $U -Replace @{extensionAttribute13 = "REPORT_TO_SOA"} -Server $DCTieto
        }
    if ($employeeType -like "l")
        {
         Set-ADUser $U -Replace @{employeeType = "k"} -Server $DCTieto
        }
    if ($employeeType -like "k")
        {
         Set-ADUser $U -Replace @{extensionAttribute13 = "REPORT_TO_SOA"} -Server $DCTieto
        }
    If ($User.NoSmartcardreq -notlike "x")
        {
         Set-ADUser $U -Replace @{userAccountControl = "262656"} -Server $DCTieto
        }
    If ($SthlmFakturaRef -NotMatch "^\d+$")
        {
         Set-ADUser $U -Clear SthlmFakturaRef -Server $DCTieto
        }
    else
        {
         Set-ADUser $U -Replace @{SthlmFakturaRef = "$SthlmFakturaRef"} -Server $DCTieto 
        }
}

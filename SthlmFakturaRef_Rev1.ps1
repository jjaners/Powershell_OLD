
# === Test file properties SthlmFakturaRef ===

$DCTieto = "wsdc003.ad.stockholm.se"

$UserCSVs = import-csv "D:\PSInData\SthlmFakturaRef\362_Micasa.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate, SthlmFakturaRef -Delimiter ","
#$UserCSVs = import-csv "D:\PSInData\Users-Migration\overforingsunderlag_Users_709_Norrmalm-20191003.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate, SthlmFakturaRef -Delimiter ","
#$Users = Get-ADUser $Userscsv.SamAccountName | select -ExpandProperty SamaccountName
#$users
#$UserCSVs.SthlmFakturaRef

foreach ($UserCSV in $UserCSVs)
{
    $U = $UserCSV.SamAccountName
    $Ref = $UserCSV.SthlmFakturaRef
    $OldRef = Get-ADUser $U -Properties SthlmFakturaRef | select SthlmFakturaRef
    
    Write-Host " "
    $U
    $Ref
    $OldRef
    Write-Host " "

    #Get-ADUser $U -Properties SamAccountName, SthlmFakturaRef | select SamAccountName, SthlmFakturaRef
    #$User = Get-ADUser $UserCSV.SamAccountName | select -ExpandProperty SamAccountName
    #Set-ADUser $U -Replace @{SthlmFakturaRef = "$Ref"} -Server $DCTieto #-WhatIf
    # $UserCSV.SamAccountName
}

#set-aduser -identity testuser -HomeDrive "P:" -HomeDirectory "\\server\path\$($_.SameAccountName)"
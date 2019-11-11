

#Steg1
#Move the user from HCL
$cred = Get-Credential
$Pxy = New-WebServiceProxy -Uri "http://ws00970.ad.stockholm.se/HCL.Sthlm.MigrationServices.Service/MigrationServices.svc" -Credential $cred -Namespace WsProxy

#Load array for user that should move.
$SamaccountList=import-csv -Path '\\wsinfra001\c$\Scripts\Mikael\Prod-Move-Users\RealTestUsers\List\List-User-2019-05-24-SLK-First-5-Users.csv' -Delimiter ";" -Header "SamAccountname"
$SamaccountList = "AF59209"


#Test if the Users Exist
$SamaccountList | %{Get-ADUser $_.SamAccountname -Properties *} | Out-GridView

#Move One user at the time
$Pxy.GetUserMigrationInfo("AG05745")
$results01=$pxy.MigrateUser("AF59209", $null, "Tieto-Prod-20190509-1354", $true, $true)



#Move many user
$ToDayDate=Get-Date -Format "yyyyMMdd-HHmm"
$Batchname="Tieto-Prod-$ToDayDate"
$Results = @()
foreach ($User in $SamaccountList){
#write-host $User.SamAccountname
$MigUser=$user.SamAccountname

$results01=$pxy.MigrateUser($MigUser, $null, $Batchname, $true, $true)

$Results += $results01
}

$Results | Out-GridView
$Results | export-csv -Path C:\Scripts\Mikael\Prod-Move-Users\RealTestUsers\Reports\Log-$Batchname.csv -Delimiter ";" -Encoding UTF8 -NoTypeInformation

#Test and show status of batches
$pxy.GetUsedBatches()
$pxy.GetUserStatusForBatch("Tieto-Prod-20190524-1718") | select Uid,MigrationStatus,HrVerksamhetsNamn,IsMigrated  | ft -AutoSize
$MigBatchStatus=$pxy.GetUserStatusForBatch("Tieto-Prod-20190510-0830")
$MigBatchStatus | select Uid,MigrationStatus,HrVerksamhetsNamn,IsMigrated  | ft -AutoSize


#Steg2
#Move Users from DMZ to Tieto. (For test Users own OU.)
$SamaccountList=import-csv -Path '\\wsinfra001\c$\Scripts\Mikael\Prod-Move-Users\RealTestUsers\List\List-User-2019-05-23-Leave-in-DMZ.csv'  -Delimiter ";" -Header "SamAccountname"
$SamaccountList = "AF55833"

$MoveToOUUser="OU=CoS-TestUsers,OU=Users,OU=CoS,DC=ad,DC=stockholm,DC=se"
$MoveToOUUser="OU=Users,OU=CoS,DC=ad,DC=stockholm,DC=se"
$DCTieto = "wsdc003.ad.stockholm.se"
$DCTieto = "WS00002.AD.STOCKHOLM.SE"

#Backup of HomeDirectory and Homedrive
$SamaccountList | %{Get-ADUser $_.SamAccountname -Properties displayname,homeDirectory,homeDrive } | select SamAccountName,DisplayName,homeDirectory,homeDrive | Export-Csv -Path '\\wsinfra001\c$\Scripts\Mikael\Prod-Move-Users\RealTestUsers\Backup-HomeDrive\List-User-2019-05-24-SLK-First-5-Users-Backup.csv' -Encoding UTF8 -Delimiter ";" -NoTypeInformation
$SamaccountList | %{Set-ADUser $_.SamAccountname -HomeDirectory $null -HomeDrive $null}



foreach ($User in $SamaccountList){

#Need to set this first. Michael want this to be on the account before object are moved to Users.
set-aduser -Identity $User.SamAccountname -Add @{'Pager'="NEED_TIETO_ONBOARDING"} -Server $DCTieto

Get-ADUser $User.SamAccountname -Server $DCTieto | Move-ADObject -TargetPat $MoveToOUUser -Server $DCTieto


#AD Groups
Add-ADGroupMember "Tieto Readers" -Members $User.SamAccountname -Server $DCTieto
Add-ADGroupMember "Cos Readers" -Members $User.SamAccountname -Server $DCTieto

#HCP Homefolders
Add-ADGroupMember "Role-T1-HCPaw-production" -Members $User.SamAccountname -Server $DCTieto

#Citrix Remote Desktop Group (All Users should be in this group)
Add-ADGroupMember "sec-CoS-VDB-App-FJARR" -Members $User.SamAccountname -Server $DCTieto

#Mobile Iron. All users should be in this group. It should be used a dynamic group but till then this group are a global one. THe user can be in both. And it works.
Add-ADGroupMember "MobileIron-All-Users" -Members $User.SamAccountname -Server $DCTieto


#Make sthlmVerksamhetsId same as sthlmForvaltningsNr  
$GetUser=Get-ADUser $User.SamAccountname -Properties sthlmVerksamhetsId,sthlmForvaltningsNr
$GetUser | %{Set-ADUser $GetUser.SamAccountName -Replace @{'sthlmVerksamhetsId'=$GetUser.sthlmForvaltningsNr} -Server $DCTieto}

#Empty this value sthlmKontoTyp
Set-ADUser $User.SamAccountname -Clear sthlmKontoTyp -Server $DCTieto

#Enable Smart Card Required [Enabled from 20190520 and forward.] set Uaccesscontrol value 262656
Set-ADUser $User.SamAccountname  -SmartcardLogonRequired $true

}



<#
#Move the user from HCL
$cred = Get-Credential
$Pxy = New-WebServiceProxy -Uri "http://ws00970.ad.stockholm.se/HCL.Sthlm.MigrationServices.Service/MigrationServices.svc" -Credential $cred -Namespace WsProxy

#Load array for user that should move.
# (create a variable for the filename)
$SamaccountList = import-csv -Path C:\Scripts\Mikael\Prod-Move-Users\RealTestUsers\List\List-User-2019-05-06.csv -Delimiter ";" -Header "SamAccountname"

#Test if the Users Exist
$SamaccountList | %{Get-ADUser $_.SamAccountname} #| Out-GridView

#Move One user at the time
#$Pxy.GetUserMigrationInfo("AF55834")
#$results01=$pxy.MigrateUser("AF55834", $null, "Tieto-Prod-20190415-1030", $true, $true)

#Move many user
$date = get-date
$ToDayDate = $date.ToString("yyyyMMdd-HHMM")
$Batchname = "Tieto-Prod-$ToDayDate"
$Results = @()
foreach ($User in $SamaccountList){
#write-host $User.SamAccountname
$MigUser = $user.SamAccountname

$results01 = $pxy.MigrateUser($MigUser, $null, $Batchname, $true, $true)

$Results += $results01
}

#$Results | Out-GridView
$Results | export-csv -Path C:\Scripts\Mikael\Prod-Move-Users\RealTestUsers\Reports\Log-$Batchname.csv -Delimiter ";" -Encoding UTF8 -NoTypeInformation

#Test and show status of batches
$pxy.GetUsedBatches()
$MigBatchStatus = $pxy.GetUserStatusForBatch("Tieto-Prod-20190506-0905")
$MigBatchStatus | select Uid,MigrationStatus,HrVerksamhetsNamn,IsMigrated  | ft -AutoSize


#Move Users from DMZ to Tieto. (For test Users own OU.)
$SamaccountList = import-csv -Path C:\Scripts\Mikael\Prod-Move-Users\RealTestUsers\List\List-User-2019-05-06.csv -Delimiter ";"
$SamaccountList = "AF55834"

$MoveToOUUser = "OU=CoS-TestUsers,OU=Users,OU=CoS,DC=ad,DC=stockholm,DC=se"
$DCTieto = "wsdc003.ad.stockholm.se"

foreach ($User in $SamaccountList){
Get-ADUser $User.SamAccountname -Server $DCTieto | Move-ADObject -TargetPat $MoveToOUUser -Server $DCTieto

set-aduser -Identity $User.SamAccountname -Add @{'Pager'="NEED_TIETO_ONBOARDING"} -Server $DCTieto

#AD Groups
Add-ADGroupMember "Tieto Readers" -Members $User.SamAccountname -Server $DCTieto
Add-ADGroupMember "Cos Readers" -Members $User.SamAccountname -Server $DCTieto

#HCP Homefolders
Add-ADGroupMember "Role-T1-HCPaw-production" -Members $User.SamAccountname -Server $DCTieto

#Citrix Remote Desktop Group (All Users should be in this group)
Add-ADGroupMember "sec-CoS-VDB-App-FJARR" -Members $User.SamAccountname -Server $DCTieto

#Make sthlmVerksamhetsId same as sthlmForvaltningsNr  
$GetUser=Get-ADUser $User.SamAccountname -Properties sthlmVerksamhetsId,sthlmForvaltningsNr
$GetUser | %{Set-ADUser $GetUser.SamAccountName -Replace @{'sthlmVerksamhetsId'=$GetUser.sthlmForvaltningsNr} -Server $DCTieto}

#Empty this value sthlmKontoTyp
Set-ADUser $User.SamAccountname -Clear sthlmKontoTyp -Server $DCTieto

#Enable Smart Card Required [Dont do this right know!!]
#Set-ADUser $User.SamAccountname  -SmartcardLogonRequired $true

}
#>
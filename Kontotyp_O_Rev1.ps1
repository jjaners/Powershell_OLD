

#Connect to DS and export O accounts
$dscred = Get-Credential -Credential sthlm\cadme001

Get-ADUser -Filter {employeetype -like "o"} -server ds.stockholm.se -Credential $dscred -Properties * | 
select SamAccountName,displayName,Name,givenName,sn,employeeType,manager,description,sthlmKontoTyp,sthlmVerksamhetsId,uid,userAccountControl,extensionAttribute14,extensionAttribute15,sthlmForvaltningsNr |
export-csv '\\wsinfra001\c$\Scripts\Mikael\Repport\DS-Usertype-o.csv' -Encoding UTF8 -Delimiter ";" -NoTypeInformation


#Paraply Users
$Users = @" 
af21064
af26592
af26593
af26594
"@ -split "`n" | % { $_.trim() }

#Prod Take out list.
$dctieto = "wsdc003.ad.stockholm.se"
$Users=Get-ADUser -Filter {employeeType -like "o" -and pager -eq "NEED_TIETO_ONBOARDING" } -SearchBase "OU=Users,OU=CoS,DC=ad,DC=stockholm,DC=se" -Properties employeeType,pager

#Export the list
$users | %{get-aduser $_.SamAccountName  -Properties * -Server $dctieto | select SamAccountName,displayName,Name,givenName,sn,employeeType,manager,description,sthlmKontoTyp,sthlmVerksamhetsId,uid,userAccountControl,extensionAttribute14,extensionAttribute15,sthlmForvaltningsNr,pager,homeDirectory,msExchHomeServerName,msRTCSIP-PrimaryHomeServer,account*} |
export-csv -Path '\\wsinfra001\c$\Scripts\Mikael\Repport\AD-UsersType-o-Convert2019-09-11.csv' -Encoding UTF8 -Delimiter ";" -NoTypeInformation

#Find Paraply Users
$ParaplyUsers=import-csv C:\Scripts\Mikael\Convert-UserType\Paraply-Account.csv -Delimiter ";"

$FindParaplyUsers = @()
foreach ($OUSer in $users)
{
    $Samaccountname=$OUSer.samaccountname
    
    $FindParaplyUsers += $ParaplyUsers | where name -EQ $Samaccountname
    
}

$FindParaplyUsers

#Import the changes.
$ChangeOUsers=Import-Csv -Path '\\wsinfra001\c$\Scripts\Mikael\Convert-UserType\Prod-List\AD-UsersType-o-Convert2019-08-26-Work.csv' -Delimiter ";"

foreach ($changeOUser in $ChangeOUsers){
$DisplayNameChange = $changeOUser.givenName + " " + $changeOUser.sn

Set-ADUser -Identity $changeOUser.SamAccountName -DisplayName $DisplayNameChange -Surname $changeOUser.sn -GivenName $ChangeOUser.givenName -Server $dctieto

}

$ChangeOUsers | %{get-aduser $_.SamAccountName  -Properties * -Server $dctieto | select SamAccountName,displayName,Name,givenName,sn,employeeType,manager,description,sthlmKontoTyp,sthlmVerksamhetsId,uid,userAccountControl,extensionAttribute14,extensionAttribute15,sthlmForvaltningsNr,pager,homeDirectory,msExchHomeServerName,msRTCSIP-PrimaryHomeServer,account*} | Out-GridView



#Create User for test in DS.
$CreateUsers=import-csv '\\wsinfra001\c$\Scripts\Mikael\Repport\AD-UsersType-o-Paraply-Users.csv' -Delimiter ";"
$TestOUPath= "OU=Test-Users,OU=CoS,DC=ds,DC=stockholm,DC=se"
$PasswordTestUsers = 
foreach($CreateUser in $CreateUsers){
$Suffix="-ds"
$UPNSuffix="@ds.stockholm.se"
$samaccountname= $CreateUser.SamAccountName + $Suffix
$UPN=$samaccountname + $UPNSuffix



New-ADUser -SamAccountName $samaccountname -DisplayName $CreateUser.displayName -Name $CreateUser.Name -UserPrincipalName $UPN -GivenName $CreateUser.givenName -Surname $CreateUser.sn -Manager muser01 -Path $TestOUPath -Description $CreateUser.description -AccountExpirationDate $CreateUser.AccountExpirationDate  -OtherAttributes @{'employeeType'="o";'sthlmKontoTyp'=$CreateUser.sthlmKontoTyp;'sthlmVerksamhetsId'=$CreateUser.sthlmVerksamhetsId;'uid'=$samaccountname;'sthlmForvaltningsNr'=$CreateUser.sthlmForvaltningsNr} -Server ds.stockholm.se -Credential $dscred
Set-ADAccountPassword -Identity $samaccountname -NewPassword (ConvertTo-SecureString “Sec1234ABC!_" -AsPlainText -Force) -Reset -Server ds.stockholm.se -Credential $dscred 
Set-ADUser -Identity $samaccountname -Replace @{'userAccountControl'=$CreateUser.userAccountControl} -Server ds.stockholm.se -Credential $dscred

}


#Take User OUT and change them.
foreach ($user01 in $users){
$dsSuffix="-ds"
$dsuser=$user01 + $dsSuffix
    get-aduser $dsuser -Properties * -Server wsdc007.ds.stockholm.se -Credential $dscred | 
        select SamAccountName,displayName,Name,givenName,sn,employeeType,manager,description,sthlmKontoTyp,sthlmVerksamhetsId,uid,userAccountControl,extensionAttribute14,extensionAttribute15,sthlmForvaltningsNr,account* |
        export-csv -Path '\\wsinfra001\c$\Scripts\Mikael\Repport\DS-UsersType-o-Paraply-Users-Test02.csv' -Append -Encoding UTF8 -Delimiter ";" -NoTypeInformation
}

#From the change CSV file. Change on the user object.
#Import the changed file
$changeUsers=import-csv '\\wsinfra001\c$\Scripts\Mikael\Convert-UserType\Test\DS-UsersType-o-Paraply-Users-Test02-change.csv' -Delimiter ";"

#Change on the account. (Opersonliga, employeetype=o)
$Server="ds.stockholm.se"
#$Server="wsdc003.ad.stockholm.se"

#Configure against ds.
foreach($changeUser in $changeUsers){
$NewDisplayname=$changeUser.givenName + " " + $changeUser.sn

Set-ADUser -Identity $changeUser.SamAccountName `
    -DisplayName $NewDisplayname `
    -Surname $changeUser.sn `
    -Replace @{'employeeType'="o";'sthlmKontoTyp'="0";'sthlmVerksamhetsId'=$changeUser.sthlmForvaltningsNr;'userAccountControl'=$changeUser.userAccountControl} `
    -Server $Server `
    -Credential $dscred `
    #-WhatIf `

}

$changeUsers | %{get-aduser $_.SamAccountName -Properties * -Server ds.stockholm.se -Credential $dscred | select SamAccountName,displayName,Name,givenName,sn,employeeType,manager,description,sthlmKontoTyp,sthlmVerksamhetsId,uid,userAccountControl,extensionAttribute14,extensionAttribute15,sthlmForvaltningsNr,account*} | Out-GridView
Export-Csv -Path '\\wsinfra001\c$\Scripts\Mikael\Repport\DS-UsersType-o-Paraply-Users-Test01-results.csv' -Encoding UTF8 -Delimiter ";" -NoTypeInformation


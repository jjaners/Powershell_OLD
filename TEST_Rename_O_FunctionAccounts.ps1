# === Variables ===
$Date = get-date -Format yyyyMMdd
$ParaplyFunk = "Funktionskonto för ParaplyPC"
$NoResourceFunk = "Funktionskonto helt utan resurser"
$AllResourceFunk = "Funktionskonto med mail skype"

# === Prod Take out list ===
$dctieto = "wsdc003.ad.stockholm.se"
#$Users = Get-ADUser -Filter {employeeType -like "o" -and pager -eq "NEED_TIETO_ONBOARDING" } -SearchBase "OU=Users,OU=CoS,DC=ad,DC=stockholm,DC=se" -Properties SamAccountName,displayName,Name,givenName,sn,employeeType,manager,description,sthlmKontoTyp,sthlmVerksamhetsId,uid,userAccountControl,extensionAttribute14,extensionAttribute15,sthlmForvaltningsNr,pager
$Users = Get-ADUser -Filter {employeeType -like "o" -and pager -eq "NEED_TIETO_ONBOARDING" } -SearchBase "OU=Users,OU=CoS,DC=ad,DC=stockholm,DC=se" -Properties employeeType,pager

$users | %{get-aduser $_.SamAccountName  -Properties * -Server $dctieto | select SamAccountName,displayName,Name,givenName,sn,employeeType,manager,description,sthlmKontoTyp,sthlmVerksamhetsId,uid,userAccountControl,extensionAttribute14,extensionAttribute15,sthlmForvaltningsNr,pager,homeDirectory,msExchHomeServerName,msRTCSIP-PrimaryHomeServer,account*} |
export-csv -Path "D:\Logs\Report\AD-UsersType-o-Convert_$date.csv" -Encoding UTF8 -Delimiter ";" -NoTypeInformation

# === Backup ===
#Copy-Item "D:\Logs\Report\AD-UsersType-o-Convert_$date.csv" -Destination "D:\Backup\O_Accounts_Backup\"
#Rename-Item "D:\Backup\O_Accounts_Backup\AD-UsersType-o-Convert_$date.csv" -NewName "D:\Backup\O_Accounts_Backup\O_Accounts_Backup_$date.csv"

# === Import lists for Looping ===
$ChangeOUsers = Import-Csv -Path "D:\Logs\Report\AD-UsersType-o-Convert_$date.csv" -Delimiter ";" -Header SamAccountName,displayName,Name,givenName,sn,employeeType,manager,description,sthlmKontoTyp,sthlmVerksamhetsId,uid,userAccountControl,extensionAttribute14,extensionAttribute15,sthlmForvaltningsNr,pager,homeDirectory,msExchHomeServerName,msRTCSIP-PrimaryHomeServer,account* | select -Skip 1
$ParaplyUsers = import-csv "D:\PSInData\Users-Migration\Convert-UserType\Paraply-Account.csv" -Delimiter ";" -Header Name,DisplayName,SN,GivenName,Company,Department

#$disp = @()
# === Loop and change users ===
foreach ($ChangeOUser in $ChangeOUsers)
{
    #$U = Get-ADUser "$ChangeOUser" -Properties SamAccountName, GivenName, Surname, Displayname, msExchHomeServerName, msRTCSIP-PrimaryHomeServer
    #$U
    $Sam = $ChangeOUser.SamAccountName
    $givenname = $ChangeOUser.GivenName
    $Surname = $ChangeOUser.Sn
    $Displayname = $ChangeOUser.Displayname

    #$Sam
    #$givenname
    #$Surname
    #$Displayname

    #}
       
    #OLDLINE #$ChangeOSam = Get-ADUser $ChangeOUser.SamAccountName | select -ExpandProperty samaccountname
    
    #$NewGivenName = $givenname + " " + $Surname
    #Set-ADUser "$Sam" -Replace @{GivenName = "$NewGivenName"} -Server $dctieto #-WhatIf
    #OLDLINE #Set-ADUser -Identity $changeOUser.SamAccountName -GivenName $NewGivenName -Server $dctieto
    
    if ($ParaplyUsers.Name -contains $Sam)
    {
        Write-Host " "
        Write-Host "$Sam $ParaplyFunk" -ForegroundColor Green
        Write-Host "$Displayname" -ForegroundColor Green
        Write-Host " "
        #Set-ADUser "$Sam" -Replace @{sn = "$ParaplyFunk"} -Server $dctieto #-WhatIf
        #OLDLINE #Set-ADUser -Identity $ChangeOSam -Surname $ParaplyFunk
        #*** NEW DisplayName Function ***
        #$NewDisplayname = $NewGivenName + " " + $ParaplyFunk
        #Set-ADUser "$Sam" -Replace @{DisplayName = "$NewDisplayname"} -Server $dctieto #-WhatIf
        #OLDLINE #Set-ADUser -Identity $ChangeOSam -DisplayName $NewDisplayname
    }
    else
    {
        $user = Get-ADUser $Sam -Properties msExchHomeServerName
        if($user.PSObject.Properties.Match('msExchHomeServerName').Count)
        #((get-aduser "$Sam" -properties msExchHomeServerName,"msRTCSIP-PrimaryHomeServer" | where {($_.msExchHomeServerName -eq $False) -and ($_."msRTCSIP-PrimaryHomeServer" -eq $False)}) -like $True)
        #(Get-Member -InputObject $Sam -Name msExchHomeServerName -MemberType Properties)
        #if ((get-aduser "$Sam" -properties msExchHomeServerName,"msRTCSIP-PrimaryHomeServer" | where {($_.msExchHomeServerName -eq $null) -or ($_."msRTCSIP-PrimaryHomeServer" -eq $null)}) -like $True)
    #{
    #       Write-Host "SomeProperty: $($testObject.SomeProperty)"
    #}
        { #and
            Write-Host " "
            Write-Host "$Sam $AllResourceFunk" -ForegroundColor DarkCyan
            Write-Host "$Displayname" -ForegroundColor DarkCyan
            Write-Host " "
            #Set-ADUser "$Sam" -Replace @{sn = "$AllResourceFunk"} -Server $dctieto #-WhatIf
            #OLDLINE #Set-ADUser -Identity $ChangeOSam -Surname $AllResourceFunk
            #*** NEW DisplayName Function ***
            #$NewDisplayname = $NewGivenName + " " + $AllResourceFunk
            #Set-ADUser "$Sam" -Replace @{DisplayName = "$NewDisplayname"} -Server $dctieto #-WhatIf
            #OLDLINE #Set-ADUser -Identity $ChangeOSam -DisplayName $NewDisplayname
        }
    
        else
        {
            Write-Host " "
            Write-Host "$Sam $NoResourceFunk" -ForegroundColor Cyan
            Write-Host "$Displayname" -ForegroundColor Cyan
            Write-Host " "
            #Set-ADUser "$Sam" -Replace @{sn = "$NoResourceFunk"} -Server $dctieto #-WhatIf
            #OLDLINE #Set-ADUser -Identity $ChangeOSam -Surname $NoResourceFunk
            #*** NEW DisplayName Function ***
            #$NewDisplayname = $NewGivenName + " " + $NoResourceFunk
            #Set-ADUser "$Sam" -Replace @{DisplayName = "$NewDisplayname"} -Server $dctieto #-WhatIf
            #OLDLINE #Set-ADUser -Identity $ChangeOSam -DisplayName $NewDisplayname
            
        }
    }    

    }

#}

Remove-Item "D:\Logs\Report\AD-UsersType-o-Convert_$date.csv"

# === Checkup strings ===
<#
# Check Paraply users
$PtoCheck = foreach ($name in $ParaplyUsers.name) {Get-ADUser $name -Properties Samaccountname,employeeType,pager | Where-Object {($_.employeetype -like "o" -and $_.pager -eq "NEED_TIETO_ONBOARDING")} }
($PtoCheck).count

#>

#Move Mailbox Object Prod

#Login to webservice
$cred = Get-Credential
$Pxy = New-WebServiceProxy -Uri "http://ws00970.ad.stockholm.se/HCL.Sthlm.MigrationServices.Service/MigrationServices.svc" -Credential $cred -Namespace WsProxy


#Move mailbox user object through web service
#Import users.
#$User="AB67959"
$SharedMailboxesList=import-csv -Path 'D:\PSInData\Users-Migration\Shared-Mailboxes\mailresources-before-Summer-20190618.csv' -Delimiter ";"

#Envirement settings
#Comment are the same. It just that we need to have something.
$Comment= "GSIT2.0"
$DCTieto = "wsdc003.ad.stockholm.se"
#$DCTieto = "ws00002.ad.stockholm.se"

$ToDayDate=Get-Date -Format "yyyyMMdd-HHmm"
$Batchname="Shared-Mailbox-Log-$ToDayDate"

#Call out of HCL webservice

$Results = @()
foreach ($sharedmailbox in $SharedMailboxesList){
$samaccountname = $sharedmailbox.SamAccountName

$results01=$Pxy.MigrateMsxResource($samaccountname,$Comment)

$Results += $results01
}

$Results | Out-GridView
$Results | export-csv -Path D:\Powershell\Mikael\Move-Shared-Mailboxes\Logs\$Batchname.csv -Delimiter ";" -Encoding UTF8 -NoTypeInformation

Write-Host "Waiting for replication to DMZ for 30min"
$time = get-date -Format HH:mm
Write-Host "Starting replication sleep time: $time"
Start-Sleep -Seconds 1800
Write-Host "$time Continuing the skript"
#Read-Host -Prompt "Press Enter to proceed"
#####STOP HERE AND WAITE FORE THE OBJECT IN DMZ#################

#Move Object to User OU
$DCTieto = "wsdc003.ad.stockholm.se"
$users = $SharedMailboxesList.samaccountname

foreach ($User in $Users)
{
      #  Write-Host "$user"}

    #$UserSam = Get-ADUser -Identity $user | select samaccountname
    $DN = Get-ADUser $user -Properties distinguishedname -Server $DCTieto | select -ExpandProperty distinguishedname
    
    # Move to Users_JJ
    Move-ADObject -Identity "$DN" -TargetPath "OU=Users,OU=CoS,DC=ad,DC=stockholm,DC=se" -Server $DCTieto
    
}


# Set Attribribute on the User Objects
$users = $SharedMailboxesList
foreach ($User in $Users)
{
    $U = $user.SamAccountName
    #$X = $User.NoSmartcardreq
    # Write-Host $U, $X }
        
    # Per user variables
    #$employeeType = Get-ADUser $U -Properties employeeType -Server $DCTieto | select -ExpandProperty employeeType
    #$NoSmartcardreq = Get-ADUser $U -Properties employeeType -Server $DCTieto | select -ExpandProperty employeeType
    
    # Need to set this first. Michael want this to be on the account before object are moved to Users.
    set-aduser -Identity $U -Replace @{Pager="NEED_TIETO_ONBOARDING"} -Server $DCTieto

    # Remove Homedrirectory and Homedrive
    #set-aduser -Identity $U -Clear HomeDirectory -Server $DCTieto
    #Set-ADUser -Identity $U -Clear HomeDrive -Server $DCTieto
    
    #Make sthlmVerksamhetsId same as sthlmForvaltningsNr  
    $GetUser = Get-ADUser $U -Properties sthlmVerksamhetsId, sthlmForvaltningsNr -Server $DCTieto
    $GetUser | %{Set-ADUser $U -Replace @{sthlmVerksamhetsId = $GetUser.sthlmForvaltningsNr} -Server $DCTieto}

    #Empty this value sthlmKontoTyp
    Set-ADUser $U -Clear sthlmKontoTyp -Server $DCTieto

    #Set employeetype to m
    Set-ADUser $U -Replace @{employeeType = "m"} -Server $DCTieto

}


##########  Change Useraccountcontrol  #########################

########## Set right Useraccountcontrol value ################
# 512       Enabled   (Normal) Keep or convert to 66048
# 514       Disabled  Keep 514
# 66048 Enabled,  Password Doesn’t Expire Keep 66048 *new*
# 66050 Disabled, Password Doesn’t Expire Convert to 514
# 66082     Disabled, Password Doesn’t Expire & Password Not Required Convert to 514
# 66080     Enabled,  Password Doesn’t Expire & Password Not Required Convert to 66048
##############################################################

#$SharedMailboxesList=import-csv -Path 'D:\PSInData\Users-Migration\Shared-Mailboxes\mailresources-before-Summer-20190618.csv' -Delimiter ";"
$ListUsersUAC=$SharedMailboxesList | %{Get-ADUser -Identity $_.samaccountname -Properties employeetype,useraccountcontrol  | select distinguishedName,samaccountname,employeetype,useraccountcontrol}
$ListUsersUAC=$ListUsersUAC | where distinguishedName -Like "*OU=Users,OU=CoS,DC=ad,DC=stockholm,DC=se"

###512 convert to 66048###
$512_66048=$ListUsersUAC | where useraccountcontrol -EQ "512"
###66050 convert to 514###
$66050_514=$ListUsersUAC | where useraccountcontrol -EQ "66050"
###66080 convert to 66048###
$66080_66048=$ListUsersUAC | where useraccountcontrol -EQ "66080"
###66082 convert to 514###
$66082_514=$ListUsersUAC | where useraccountcontrol -EQ "66082"


$512_66048 | %{Set-ADUser $_.samaccountname -Replace @{'useraccountcontrol'=66048} -Server $DCTieto}
$66050_514 | %{Set-ADUser $_.samaccountname -Replace @{'useraccountcontrol'=514} -Server $DCTieto }
$66080_66048 | %{Set-ADUser $_.samaccountname -Replace @{'useraccountcontrol'=66048} -Server $DCTieto}
$66082_514 | %{Set-ADUser $_.samaccountname -Replace @{'useraccountcontrol'=514} -Server $DCTieto }


<#
Set-ADUser muser01 -Replace @{employeeType = "m"} -Server $DCTieto
Get-ADUser muser01 -Properties * -Server $DCTieto | select empl*
#>


<##########Should not bee needed##############
#Put User Object to Groups

$users = $SharedMailboxesList.samaccountname

foreach ($User in $Users)
{
    #Write-Host "$user"}

    Add-ADGroupMember -Identity "Tieto Readers" -Members $User -Server $DCTieto
    Add-ADGroupMember -Identity "Cos Readers" -Members $User -Server $DCTieto
    
}
#>

##Connecting to Exchange#####################

$User = "crSCRIPT-Migration"
$PWord = ConvertTo-SecureString "YrAddHyxZ5m8VvSmZdnQmFFWu64ba4%47dWCrBjPn48Ce8WP" -AsPlainText -Force #"YrAddHyxZ5m8VvSmZdnQmFFWu64ba4%47dWCrBjPn48Ce8WP"
$Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $User, $PWord

$SessionOpt = New-PSSessionOption -SkipCACheck:$true -SkipCNCheck:$true -SkipRevocationCheck:$true
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://wsex001/powershell/ -Credential $Credential -SessionOption $SessionOpt
Import-PSSession $Session

##Set Time #########
$DCTieto      = "wsdc003.ad.stockholm.se"
$dateshort    = get-date -Format "MM/dd/yyyy"
$Time         = " 07:00:00 PM"
$dateComplete = $dateshort + $Time

$users = $SharedMailboxesList.samaccountname

foreach ($user in $users){

Set-MoveRequest -Identity $user -CompleteAfter $dateComplete -DomainController $DCTieto #-WhatIf
}

<#
foreach ($user in $users){

get-MoveRequest -Identity $user -DomainController $DCTieto | select DistinguishedName,Status
}

#>

####Remove session with Exchange#####################
Remove-PSSession $Session

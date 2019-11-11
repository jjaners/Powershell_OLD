Import-Module ActiveDirectory

$dctieto = "wsdc003.ad.stockholm.se"

$Userlist = Get-ADUser -Filter {employeeType -like "o" -and pager -eq "NEED_TIETO_ONBOARDING" } -SearchBase "OU=Users,OU=CoS,DC=ad,DC=stockholm,DC=se" -Properties SamAccountName | select -ExpandProperty SamAccountName

foreach ($User in $Userlist)
{
    $U = Get-ADUser $User -Properties SamAccountName, Displayname, GivenName, Surname
    #$U
    $Sam = @($U.SamAccountName)
    $givenname = @($U.GivenName)
    $Surname = @($U.Surname)
    $Displayname = @($U.Displayname)
    #$Sam
    $name = $givenname.split(' ')[0] + " " + $givenname.split(' ')[1]
    #$name
    Set-ADUser "$Sam" -Replace @{GivenName = "$name"} -Server $dctieto
    #Set-ADUser $Sam -GivenName $name -Server $dctieto
    #  -Identity
    #Write-Host "$givenname $Surname"

}


#$OUsers = Get-ADUser -Filter {employeeType -like "o"} -Properties givenname, surname | select givenname, surname
#$ousers = Get-ADUser -Filter {employeeType -like "o" -and pager -eq "NEED_TIETO_ONBOARDING" } -SearchBase "OU=Users,OU=CoS,DC=ad,DC=stockholm,DC=se" -Properties givenname, surname | select givenname, surname
#$OUsers
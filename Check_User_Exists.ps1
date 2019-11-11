


# Access Active Directory PowerShell Commands.
Import-Module ActiveDirectory -ErrorAction SilentlyContinue
# Import List Of Accounts From CSV.
$ListOfAccounts = IMPORT-CSV D:\PSInData\Users-Migration\BaseFile\combined_20190610.csv -Header ("samaccountname")
FOREACH ($Account in $ListOfAccounts)
{
    
    # If the account exists, inform, if it does not exist also inform.
    $Username = $Account.samaccountname
    If ((Get-ADUser -Filter {SamAccountName -eq $Username}) -eq $Null)
    {
        Write-Host "I am sorry, $Username does not exist."
    }
    Else
    {
        Write-Host "$Username already exists."
    }
}








<#

$users = import-csv D:\PSInData\Users-Migration\BaseFile\combined_20190610.csv -Header samaccountname | sort samaccountname | select samaccountname

foreach ($User in $users)
{
    #$username = "$firstname $lastname"
    $aduser = Get-ADUser -filter "Name -eq $user"
    if ($aduser) {
        Write-Host "user exists" -ForegroundColor Green
    } else {
        Write-Host "user doesn't exist" -ForegroundColor Red
    }
    #If ($User -ne $Null) {write-host "IN AD" -ForegroundColor Green} Else {Write-Host "NOT in AD" -ForegroundColor Red}
    #if (Get-ADUser -Filter {(sAMAccountName -like "$User")}) {write-host "User does not exist."} else {write-host "User exist."}
    <#
    get-aduser -f samaccountname -eq $user
    if($true){
        write-host "username exist" -ForegroundColor Green
    }
    else{
         write-host "user doesn't exist" -ForegroundColor Red
    }
    #>
#}
#>

# === Set Password fix ===

# === Import Module ===
Import-Module ActiveDirectory

# === Variables ===
$Date = get-date -Format yyyyMMdd

# === Script ===
$ChangePWDUsers = get-aduser -SearchBase "OU=Users,OU=CoS,DC=ad,DC=stockholm,DC=se" -SearchScope OneLevel -Properties Samaccountname, pwdlastset, SmartcardLogonRequired, employeeType -Filter * | Where-Object {$_.pwdlastset -eq "0" -and ($_.employeeType -like "F" -or $_.employeeType -like "a" -or $_.employeeType -like "v" -or $_.employeeType -like "l" -or $_.employeeType -like "k" -or $_.employeeType -like "o")}

foreach ($User in $ChangePWDUsers)
{
    Set-ADUser $User -ChangePasswordAtLogon:$False #-WhatIf
}

# === User report ===
$ChangePWDUsers | Export-Csv D:\logs\Password_Fixed_Users\Password_Fixed_Users_$date.csv
#$listusers = $ChangePWDUsers | %{Get-ADUser $_.samaccountname -Properties *}  

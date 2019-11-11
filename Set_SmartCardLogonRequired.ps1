# Set SmartCardLogonRequired on users

# Uncheck the box
#Get-ADUser -SearchBase "OU=Users_JJ,OU=Test_JJ,OU=STHLM,DC=ds,DC=stockholm,DC=se" -Filter {SmartCardLogonRequired -eq $True} | ForEach-Object {

#Set-ADUser -Identity $_ -SmartcardLogonRequired $false
#}

# check the box
Get-ADUser -SearchBase "OU=Users_JJ,OU=Test_JJ,OU=STHLM,DC=ds,DC=stockholm,DC=se" -Filter {SmartCardLogonRequired -eq $False} | ForEach-Object {

Set-ADUser -Identity $_ -SmartcardLogonRequired $true
}
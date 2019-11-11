# Attribute tester

#$Users = Get-aduser -SearchBase "OU=Users,OU=CoS,DC=ad,DC=stockholm,DC=se" -Properties Samaccountname | select samaccountname | select -First 10 | export-csv C:\Powershell\PS_Results\ADUser_first10.csv

#$users = import-csv C:\Powershell\PS_Results\ADUser_first10.csv
# $users = Get-Content C:\Powershell\PS_Results\ADUser_first10.txt

#$total = foreach ($user in $Users)
#{
    # Get-aduser $user -ldapfilter '(!(city=*))' -properties city | measure-object
 #   Get-aduser -filter {City -notlike "*"} -properties city #|  Where-Object {($user).city -ne $null}
    #Write-Host "$User" " " "($user).city"   
    
    
    
    #Write-Host "$user"
    
#}

#$total | measure-object | select count, sum


<#
City
Company
Country
Department
Division
EmployeeID
EmployeeNumber
Fax
HomePage
Initials
Manager
Office
OfficePhone
Organization
OtherNamer
POBox
PostalCode
StreetAddress
sthlmFakturaRef
StreetAddress
#>
# Messure how many of the specified Attributes that are populated



# OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se
# OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se
# Get-aduser -ldapfilter '(!(city=*))' -properties city | measure-object
# Get-aduser -SearchBase "OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se" -properties name, city -Filter * | Where-Object {$_.city -notlike $null} | Measure-Object | select count

$City = Get-aduser -SearchBase "OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se" -properties name, city -Filter * | Where-Object {$_.city -notlike $null} | Measure-Object | select -ExpandProperty count
$Company = Get-aduser -SearchBase "OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se" -properties name, Company -Filter * | Where-Object {$_.Company -notlike $null} | Measure-Object | select  -ExpandProperty count
$Country = Get-aduser -SearchBase "OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se" -properties name, Country -Filter * | Where-Object {$_.Country -notlike $null} | Measure-Object | select -ExpandProperty count
$Department = Get-aduser -SearchBase "OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se" -properties name, Department -Filter * | Where-Object {$_.Department -notlike $null} | Measure-Object | select -ExpandProperty count
$Division = Get-aduser -SearchBase "OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se" -properties name, Division -Filter * | Where-Object {$_.Division -notlike $null} | Measure-Object | select -ExpandProperty count
$EmployeeID = Get-aduser -SearchBase "OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se" -properties name, EmployeeID -Filter * | Where-Object {$_.EmployeeID -notlike $null} | Measure-Object | select -ExpandProperty count
$EmployeeNumber = Get-aduser -SearchBase "OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se" -properties name, EmployeeNumber -Filter * | Where-Object {$_.EmployeeNumber -notlike $null} | Measure-Object | select -ExpandProperty count
$Fax = Get-aduser -SearchBase "OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se" -properties name, Fax -Filter * | Where-Object {$_.Fax -notlike $null} | Measure-Object | select -ExpandProperty count
$HomePage = Get-aduser -SearchBase "OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se" -properties name, HomePage -Filter * | Where-Object {$_.HomePage -notlike $null} | Measure-Object | select -ExpandProperty count
$Initials = Get-aduser -SearchBase "OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se" -properties name, Initials -Filter * | Where-Object {$_.Initials -notlike $null} | Measure-Object | select -ExpandProperty count
$Manager = Get-aduser -SearchBase "OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se" -properties name, Manager -Filter * | Where-Object {$_.Manager -notlike $null} | Measure-Object | select -ExpandProperty count
$Office = Get-aduser -SearchBase "OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se" -properties name, Office -Filter * | Where-Object {$_.Office -notlike $null} | Measure-Object | select -ExpandProperty count
$OfficePhone = Get-aduser -SearchBase "OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se" -properties Name, OfficePhone -Filter * | Where-Object {$_.OfficePhone -notlike $null} | Measure-Object | select -ExpandProperty count
$Organization = Get-aduser -SearchBase "OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se" -properties name, Organization -Filter * | Where-Object {$_.Organization -notlike $null} | Measure-Object | select -ExpandProperty count
$OtherName = Get-aduser -SearchBase "OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se" -properties name, OtherName -Filter * | Where-Object {$_.OtherName -notlike $null} | Measure-Object | select -ExpandProperty count
$POBox = Get-aduser -SearchBase "OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se" -properties name, POBox -Filter * | Where-Object {$_.POBox -notlike $null} | Measure-Object | select -ExpandProperty count
$PostalCode = Get-aduser -SearchBase "OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se" -properties name, PostalCode -Filter * | Where-Object {$_.PostalCode -notlike $null} | Measure-Object | select -ExpandProperty count
$StreetAddress = Get-aduser -SearchBase "OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se" -properties name, StreetAddress -Filter * | Where-Object {$_.StreetAddress -notlike $null} | Measure-Object | select -ExpandProperty count
$sthlmFakturaRef = Get-aduser -SearchBase "OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se" -properties name, sthlmFakturaRef -Filter * | Where-Object {$_.sthlmFakturaRef -notlike $null} | Measure-Object | select -ExpandProperty count
$StreetAddress = Get-aduser -SearchBase "OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se" -properties name, StreetAddress -Filter * | Where-Object {$_.StreetAddress -notlike $null} | Measure-Object | select -ExpandProperty count


Write-host "City: $City"
Write-host "Company: $Company"
Write-host "Country: $Country"
Write-host "Department: $Department"
Write-host "Division: $Division"
Write-host "EmployeeID: $EmployeeID"
Write-host "EmployeeNumber: $EmployeeNumber"
Write-host "Fax: $Fax"
Write-host "HomePage: $HomePage"
Write-host "Initials: $Initials"
Write-host "Manager: $Manager"
Write-host "Office: $Office"
Write-host "OfficePhone: $OfficePhone"
Write-host "Organization: $Organization"
Write-host "OtherName: $OtherName"
Write-host "POBox: $POBox"
Write-host "PostalCode: $PostalCode"
Write-host "StreetAddress: $StreetAddress"
Write-host "sthlmFakturaRef: $sthlmFakturaRef"
Write-host "StreetAddress: $StreetAddress"

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
OtherName
POBox
PostalCode
StreetAddress
sthlmFakturaRef
StreetAddress
#>
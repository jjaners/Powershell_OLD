# Import-excel report script

$date = Read-Host "Enter date in format yyyyMMdd"

$csv = Import-Csv C:\Users\xxjanerj\Documents\Stockholms_Stad\Logs\Reports\User_Mig_Excel_Report_$date.csv -Delimiter ',' |`
select Samaccountname, ADUserExists, distinguishedName, Exchange, Skype, sthlmVerksamhetsId, sthlmForvaltningsNr, sthlmKontoTyp, userAccountControl, employeeType, ScanToFile

# Variables
$Header = New-ConditionalText -ConditionalType ContainsText -ConditionalTextColor Black -BackgroundColor Darkgray -Range "A1:K1"
$SamAccountNames = New-ConditionalText -ConditionalType ContainsText -ConditionalTextColor Black -BackgroundColor Lightgray -Range "A:A"
$ADUserInAD = New-ConditionalText -ConditionalType ContainsText 'YES' -ConditionalTextColor wheat -BackgroundColor green -Range "B:B"
$ADUserNOTInAD = New-ConditionalText -ConditionalType ContainsText 'NO' -ConditionalTextColor DarkRed -BackgroundColor LightPink -Range "B:B"
$OUText = New-ConditionalText CoS wheat green -Range "C:C"
$Exchange_1 = New-ConditionalText EXDAG01 wheat green -Range "D:D"
$Exchange_2 = New-ConditionalText EXDAG02 wheat green -Range "D:D"
$Exchange_3 = New-ConditionalText -ConditionalType NotEqual EXDAG01 -ConditionalTextColor DarkRed -BackgroundColor LightPink -Range "D:D"
$Exchange_4 = New-ConditionalText -ConditionalType ContainsText mdb -ConditionalTextColor DarkRed -BackgroundColor LightPink -Range "D:D"
$Skype_1 = New-ConditionalText '2:1' wheat green
$Skype_2 = New-ConditionalText '3:1' wheat green
$SthlmVerksamhetsID = New-ConditionalText -ConditionalType GreaterThan '1' -ConditionalTextColor wheat -BackgroundColor green -Range "F:F"
$SthlmForvaltningsNr = New-ConditionalText -ConditionalType GreaterThan '1' -ConditionalTextColor wheat -BackgroundColor green -Range "G:G"
$userAccountControl_1 = New-ConditionalText 262656 blue cyan -Range "I:I"
$userAccountControl_2 = New-ConditionalText 512 cyan blue -Range "I:I"
$userAccountControl_3 = New-Conditionaltext -ConditionalType GreaterThan '1' orange -Range "I:I"
$sthlmKontoTyp = New-ConditionalText -ConditionalType ContainsText '0' -ConditionalTextColor wheat -BackgroundColor green -Range "H:H"
$employeeType = New-ConditionalText -ConditionalType GreaterThan '1' -ConditionalTextColor wheat -BackgroundColor green -Range "J:J"
$ScanToFileTrue = New-ConditionalText -ConditionalType ContainsText 'True' -ConditionalTextColor wheat -BackgroundColor green -Range "K:K"
$ScanToFileFalse = New-ConditionalText -ConditionalType ContainsText 'False' -ConditionalTextColor DarkRed -BackgroundColor LightPink -Range "K:K"

# Out Excel file
$csv | Export-Excel C:\Users\xxjanerj\Documents\Stockholms_Stad\Logs\Reports\User_Migration_report_$date.xlsx -FreezeTopRow -BoldTopRow -Show -AutoSize -AutoFilter -ConditionalText $Header, $SamAccountNames, $ADUserInAD, $ADUserNOTInAD, $OUText, $Exchange_1, $Exchange_2, $Exchange_3, $Exchange_4, $Skype_1, $Skype_2, $SthlmVerksamhetsID, $SthlmForvaltningsNr, $userAccountControl_1, $userAccountControl_2, $userAccountControl_3, $sthlmKontoTyp, $employeeType, $ScanToFileTrue, $ScanToFileFalse

# Rm Test_Excel_Rev1.xlsx -ErrorAction Ignore

# -Show -AutoSize NotEqual
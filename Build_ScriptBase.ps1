# Create variable script

#$Attributes = Get-Content C:\Powershell\PS_Results\Non_FIM_Attributes.csv
$Attributes = Import-Csv C:\Powershell\PS_Results\All_Attributes_Get-member.csv

foreach ($Attr in $Attributes)
{
    
    #$Result = "$Attr = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, $Attr -Filter * | Where-Object {$_.$Attr -notlike $null} | Measure-Object | select -ExpandProperty count"
    
    $Result = "'Write-host $attr : '$'$Attr'"
    $Result | Out-File C:\Powershell\PS_Results\Attr_ScriptBase_2.txt -Append
}
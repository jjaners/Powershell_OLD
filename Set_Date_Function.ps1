# Set Date function

Clear-Variable -Name "DefaultDate" -Force
Clear-Variable -Name "defaultValue" -Force
Clear-Variable -Name "Date" -Force
Clear-Variable -Name "Value" -Force

$DefaultDate = get-date -Format yyyyMMdd

$defaultValue = $DefaultDate

$Date = if ($value = Read-Host -Prompt "Please enter a date OR Enter to set ($defaultValue)") { $value } else { $defaultValue }

D:\Powershell\Stockholms_Stad\Menu\Stockholm_Stad_Main_Meny.ps1

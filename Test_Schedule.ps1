# test of multiple scripts

#=== Date for file to run
$date = get-date -Date $(get-date).AddDays(1) -Format yyyyMMdd

#=== Verbose pref ===
#$VerbosePreference = "SilentlyContinue"

#=== Import Module ===
#Import-Module ActiveDirectory

#=== Start Transcript ======================================================
#$TransDate = get-date -Format yyyyMMddHHmm
Start-Transcript -Path "D:\Logs\Test_Schedule_$Date.txt" -NoClobber

$ScriptList =
@(

D:\Powershell\Stockholms_Stad\Get_Process_5.ps1

D:\Powershell\Stockholms_Stad\Get_Service_5.ps1
)

foreach ($Script in $ScriptList)
{
    Start-Process -FilePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList "-NoExit", "-command '& $Script'" -Wait
}

#=== Stop Transcript =============================================================
Stop-Transcript
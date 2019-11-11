
# Scheduled script to automate migration and do everything sequentially

#=== Date for file to run
#$date = get-date -Date $(get-date).AddDays(1) -Format yyyyMMdd
$date = read-host "Enter date in format yyyyMMdd"

#=== Verbose pref ===
$VerbosePreference="SilentlyContinue"

#=== Import Module ===
Import-Module ActiveDirectory

#=== Start Transcript ======================================================
Start-Transcript -Path "D:\Logs\Scheduled_Mig_log_$Date.txt" -NoClobber
$testpath = Test-Path D:\PSInData\Users-Migration\BaseFile\combined_$date.csv

if ($testpath -eq $False)
{
    Write-Host "  .:| No combined file exists |:.   "    
}
else
{

$ScriptList =
@(

# 1: Move users from DMZ to Tieto OU Script *FIXED*
D:\Powershell\Stockholms_Stad\Move_Users_OU_Rev2.ps1
Write-Host "Moving users from DMZ to Users OU, DONE!" #-ForegroundColor Green

# 2: Set and clear Attributes *FIXED*
D:\Powershell\Stockholms_Stad\Set-Attributes_Rev2.ps1
Write-Host "Setting Attributes, DONE!" #-ForegroundColor Green

# 3: Add Users to Groups that all users should have *FIXED*
D:\Powershell\Stockholms_Stad\Add_users_to_Groups_all_Users_Rev2.ps1
Write-Host "Add to groups for all users, DONE!" #-ForegroundColor Green

# 4: Add users to Application groups *FIXED*
D:\Powershell\Stockholms_Stad\AddTo_AppsGroups.ps1
Write-Host "Add to AppGroups, DONE!" #-ForegroundColor Green

# 5: Groupe translation script for adding users from HCL to Tieto groups *FIXED*
D:\Powershell\Stockholms_Stad\If_In_GroupA_Add_To_GroupeB_Rev2.ps1
Write-Host "GroupTranslation from HCL to Tieto groups, DONE!" #-ForegroundColor Green

# 6: Scan-To-File *FIXED*
D:\Powershell\Stockholms_Stad\Scan_To_File_Rev1.ps1
Write-Host "Scan to file folders, Created!" #-ForegroundColor Green

# 7: move Shared folders when owner moves *FIXED*
D:\Powershell\Stockholms_Stad\SFO_Move_Rev2.ps1
Write-Host "Move of Shared folders, DONE!" #-ForegroundColor Green

# 8: Exchange Finnish mailbox move
D:\Powershell\Stockholms_Stad\Exchange-Fininsh-Mailbox-move.ps1
Write-Host "Exchange Finnish mailbox move, DONE!" #-ForegroundColor Green

)
    foreach ($Script in $ScriptList)
    {
        Start-Process -FilePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList "-NoExit", "-command '& $Script'" -Wait
    }
}

#=== Stop Transcript =============================================================
Stop-Transcript
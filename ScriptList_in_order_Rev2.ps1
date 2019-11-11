# Master script to do everything sequentially

$VerbosePreference="SilentlyContinue"

#=== Variables ==================
write-host "NOTE!" -ForegroundColor DarkYellow
Write-Host "Set date variable is set once for all Scripts in ScriptList_in_order_Rev2.ps1" -ForegroundColor Cyan
$date = read-host "Enter date in format yyyyMMdd"

#=== Import Module ===
Import-Module ActiveDirectory

Read-Host -Prompt "Press Enter to proceed with Move_Users_OU"
# Move users from DMZ to Tieto OU Script *FIXED*
D:\Powershell\Stockholms_Stad\Move_Users_OU_Rev2.ps1
Write-Host "Moving users from DMZ to Users OU, DONE!" -ForegroundColor Green

Read-Host -Prompt "Press Enter to proceed with Set-Attributes"
# Set and clear Attributes *FIXED*
D:\Powershell\Stockholms_Stad\Set-Attributes_Rev2.ps1
Write-Host "Setting Attributes, DONE!" -ForegroundColor Green

Read-Host -Prompt "Press Enter to proceed with Add_users_to_Groups_all_Users"
# Add Users to Groups that all users should have *FIXED*
D:\Powershell\Stockholms_Stad\Add_users_to_Groups_all_Users_Rev2.ps1
Write-Host "Add to groups for all users, DONE!" -ForegroundColor Green

Read-Host -Prompt "Press Enter to proceed with AddTo_AppsGroups"
# Add users to Application groups *FIXED*
D:\Powershell\Stockholms_Stad\AddTo_AppsGroups.ps1
Write-Host "Add to AppGroups, DONE!" -ForegroundColor Green

Read-Host -Prompt "Press Enter to proceed with If_In_GroupA_Add_To_GroupeB"
# Groupe translation script for adding users from HCL to Tieto groups *FIXED*
D:\Powershell\Stockholms_Stad\If_In_GroupA_Add_To_GroupeB_Rev2.ps1
Write-Host "GroupTranslation from HCL to Tieto groups, DONE!" -ForegroundColor Green

Read-Host -Prompt "Press Enter to proceed with Scan_To_File"
# Scan-To-File *FIXED*
D:\Powershell\Stockholms_Stad\Scan_To_File_Rev1.ps1
Write-Host "Scan to file folders, Created!" -ForegroundColor Green

Read-Host -Prompt "Press Enter to proceed with Move_SharedFolders_n_Groups"
# move Shared folders when owner moves *FIXED*
D:\Powershell\Stockholms_Stad\Move_SharedFolders_n_Groups.ps1
Write-Host "Move of Shared folders, DONE!" -ForegroundColor Green

Read-Host -Prompt "Press Enter to proceed with Exchange Finnish mailbox move"
# Exchange Finnish mailbox move
D:\Powershell\Stockholms_Stad\Exchange-Fininsh-Mailbox-move.ps1
Write-Host "Exchange Finnish mailbox move, DONE!" -ForegroundColor Green

Write-Host "----------------------------------------------------------------------------------------------------" -ForegroundColor DarkYellow -BackgroundColor DarkBlue
Write-Host "| To see if users are changed, run script D:\Powershell\Stockholms_Stad\Test_User_ADAttributes.ps1 |" -ForegroundColor DarkYellow -BackgroundColor DarkBlue
Write-Host "----------------------------------------------------------------------------------------------------" -ForegroundColor DarkYellow -BackgroundColor DarkBlue

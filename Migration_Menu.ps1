$VerbosePreference="SilentlyContinue"


#=== Credentials =====================================================================================================================
$User = "crSCRIPT-Migration"
$PWord = ConvertTo-SecureString "YrAddHyxZ5m8VvSmZdnQmFFWu64ba4%47dWCrBjPn48Ce8WP" -AsPlainText -Force #"YrAddHyxZ5m8VvSmZdnQmFFWu64ba4%47dWCrBjPn48Ce8WP"
$Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $User, $PWord

#=== Import Module ===
Import-Module ActiveDirectory

#=== Variables ==================
write-host "NOTE!" -ForegroundColor Magenta
Write-Host "Set date variable is set once for all Scripts" -ForegroundColor Yellow
$date = read-host "Enter date in format yyyyMMdd"

function Show-Menu
{
     param (
           [string]$Title = 'Migration Menu'
     )
     cls
     Write-Host "  ----------------------------------------------------------------------------- " -ForegroundColor Yellow -BackgroundColor DarkBlue
     Write-Host "  |================== Migration Menu =========================================| " -ForegroundColor Yellow -BackgroundColor DarkBlue
     Write-Host "  ----------------------------------------------------------------------------- " -ForegroundColor Yellow -BackgroundColor DarkBlue
	 Write-Host ""
     Write-Host "  1:  Check if there is a combined file" -ForegroundColor Yellow
     Write-Host "  2:  Create a combined file (if there is none in step 1)" -ForegroundColor Yellow
     Write-Host "  3:  Move users from DMZ to CoS/Users " -ForegroundColor Yellow
     Write-Host "  4:  Set Attributes" -ForegroundColor Yellow
     Write-Host "  5:  Add users to groups common for all users" -ForegroundColor Yellow
     Write-Host "  6:  Add to Appgroups" -ForegroundColor Yellow
     Write-Host "  7:  Translate from HCL to Tieto Groups" -ForegroundColor Yellow
     Write-Host "  8:  Create Scan-to-File folders" -ForegroundColor Yellow
     Write-Host "  9:  Move shared folder and rights groups" -ForegroundColor Yellow
     Write-Host "  10: Exchange finnish mailbox move" -ForegroundColor Yellow
     Write-Host "  11: Build user report CSV" -ForegroundColor Yellow
     Write-Host "  Q:  Press 'Q' to quit." -ForegroundColor Magenta
	 Write-Host ""
}

do
{
     Show-Menu
     $input = Read-Host "Please make a selection"
     switch ($input)
     {

             '1' {
                cls
				Write-Host ""
				Write-Host ""
				Write-Host "========== 1: Check if there is a combined file ==========="
				Write-Host ""
                D:\Powershell\Stockholms_Stad\Test_CombineFile.ps1
                #Write-Host "Moving users from DMZ to Users OU, DONE!" -ForegroundColor Green
				Write-Host ""
           } '2' {
                cls
				Write-Host ""
				Write-Host ""
				Write-Host "====== 2: Create a combined file (if there is none in step 1) ======"
				Write-Host ""
                D:\Powershell\Stockholms_Stad\Create_Combinefile.ps1
                Write-Host "Creating combinefile combined_$date.csv, DONE!" -ForegroundColor Green
				Write-Host ""
          } '3' {
                cls
				Write-Host ""
				Write-Host ""
				Write-Host "========== 3: Move users from DMZ to CoS/Users ==========="
				Write-Host ""
                D:\Powershell\Stockholms_Stad\Move_Users_OU_Rev2.ps1
                Write-Host "Moving users from DMZ to Users OU, DONE!" -ForegroundColor Green
				Write-Host ""
           } '4' {
                cls
				Write-Host ""
				Write-Host ""
				Write-Host "====== 4: Set Attributes ======"
				Write-Host ""
                D:\Powershell\Stockholms_Stad\Set-Attributes_Rev2.ps1
                Write-Host "Setting Attributes, DONE!" -ForegroundColor Green
				Write-Host ""
           } '5' {
                cls
				Write-Host ""
				Write-Host ""
				Write-Host "====== 5: Add users to groups common for all users ======"
				Write-Host ""
                D:\Powershell\Stockholms_Stad\Add_users_to_Groups_all_Users_Rev2.ps1
                Write-Host "Add to groups for all users, DONE!" -ForegroundColor Green
				Write-Host ""				
                
           } '6' {
                cls
				Write-Host ""
				Write-Host ""
				Write-Host "========== 6: Add to Appgroups ==========="
				Write-Host ""
                D:\Powershell\Stockholms_Stad\AddTo_AppsGroups.ps1
                Write-Host "Add to AppGroups, DONE!" -ForegroundColor Green
				Write-Host ""

           } '7' {
                cls
				Write-Host ""
				Write-Host ""
				Write-Host "========== 7: Translate from HCL to Tieto Groups ==========="
				Write-Host ""
                D:\Powershell\Stockholms_Stad\If_In_GroupA_Add_To_GroupeB_Rev2.ps1
                Write-Host "GroupTranslation from HCL to Tieto groups, DONE!" -ForegroundColor Green
				Write-Host ""

           } '8' {
                cls
				Write-Host ""
				Write-Host ""
				Write-Host "========== 8: Create Scan-to-File folders ==========="
				Write-Host ""
                D:\Powershell\Stockholms_Stad\Scan_To_File_Rev1.ps1 -Credential $Credential
                Write-Host "Scan to file folders, Created!" -ForegroundColor Green
				Write-Host ""

           } '9' {
                cls
				Write-Host ""
				Write-Host ""
				Write-Host "========== 9: Move shared folder and rights groups ==========="
				Write-Host ""
                D:\Powershell\Stockholms_Stad\SFO_Move_Rev2.ps1
                Write-Host "Move of Shared folders, DONE!" -ForegroundColor Green
				Write-Host ""

           } '10' {
                cls
				Write-Host ""
				Write-Host ""
				Write-Host "========== 10: Exchange finnish mailbox move ==========="
				Write-Host ""
                D:\Powershell\Stockholms_Stad\Exchange-Fininsh-Mailbox-move.ps1
                Write-Host "Exchange Finnish mailbox move, DONE!" -ForegroundColor Green
				Write-Host ""

           } '11' {
                cls
				Write-Host ""
				Write-Host ""
				Write-Host "=========== 11: Build user report CSV ==========="
				Write-Host ""
                D:\Powershell\Stockholms_Stad\Build_User_Repport.PS1
                Write-Host "Report CSV, Created!" -ForegroundColor Green
				Write-Host ""
           }'q' {
                return
           }
     }
     pause
}
until ($input -eq 'q')
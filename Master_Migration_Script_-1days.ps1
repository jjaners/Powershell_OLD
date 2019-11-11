# Get in files with -1 day date

#=== Remove Old Transcript file ======================================================================================================
#RM "D:\Logs\Mig_Transcript.txt"

#=== Start Transcript ================================================================================================================
$TransDate = get-date -Format yyyyMMddHHmm
Start-Transcript -Path "D:\Logs\Mig_Transcript-1_$TransDate.txt" -NoClobber

# Credentials
$User = "crSCRIPT-Migration"
$PWord = ConvertTo-SecureString "YrAddHyxZ5m8VvSmZdnQmFFWu64ba4%47dWCrBjPn48Ce8WP" -AsPlainText -Force #"YrAddHyxZ5m8VvSmZdnQmFFWu64ba4%47dWCrBjPn48Ce8WP"
$Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $User, $PWord

# === Combine files with the same date =====================================================================================
#$Date_1 = Get-Date -date $(get-date).adddays(-1) -format yyyy-MM-dd
#$Date = Get-Date -Format yyyyMMdd
#$date = "20190610"
$date = Read-Host "Input date in format yyyyMMdd"
# $FilesShare = "\\WSADMGMT01\PSInData\Users-Migration\"
#  $Combine = Get-ChildItem -Path $FilesShare "*$date*"`
#| Select-Object -ExpandProperty FullName | Import-Csv -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate -Delimiter ";" | select -Skip 1 `
# | Export-Csv "D:\PSInData\Users-Migration\BaseFile\combined_$date.csv" -NoTypeInformation -NoClobber -Append

#=== Set CombineClean #| select -Skip 1 =============================================================================================
$CombineClean = Import-Csv "D:\PSInData\Users-Migration\BaseFile\combined_$date.csv" #| select -Skip 1
#$CombineClean = Import-Csv "D:\PSInData\Users-Migration\BaseFile\Pre-Pilot2-one-User-2019-06-05.csv"

# === Exchange Session ======================================================================================================
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://WSC01208-N1/PowerShell/ -Credential $Credential
Import-PSSession $Session -DisableNameChecking

$DCTieto      = "wsdc003.ad.stockholm.se"
$dateshort    = get-date -Format "MM/dd/yyyy"
$Time         = " 07:00:00 PM"
$dateComplete = $dateshort + $Time

# ====== Foreach =============================================================================================================

foreach ($Row in $CombineClean)
{
# ====== Account typ F/K =====================================================================================================    
    
if ($Row | Where-Object { (($_.accounttype -like "F" -or $_.accounttype -like "K"))  })
 
    {
       # Create User Variable
       $Users = $Row.Samaccountname
              
       # Move users from DMZ to Tieto OU Script (Steg 1)
       #D:\Powershell\Stockholms_Stad\Move_Users_To_UsersOU.ps1

       # Set and clear Attributes
       #D:\Powershell\Stockholms_Stad\Set-Attributes.ps1

       # Add users to Application groups
       #D:\Powershell\Stockholms_Stad\AddTo_AppsGroups.ps1

       # Add Users to Groups that all users should have
       #D:\Powershell\Stockholms_Stad\Add_users_to_Groups_all_Users.ps1

       # Groupe translation script for adding users from HCL to Tieto groups
       D:\Powershell\Stockholms_Stad\If_In_GroupA_Add_To_GroupeB_rev1.ps1

       # Shared Folder
       #D:\Powershell\Stockholms_Stad\Move_SharedFolders_n_Groups.ps1

       # Set User complet in Exchange
       #Set-MoveRequest -Identity $Users -CompleteAfter $dateComplete -DomainController $DCTieto #-WhatIf
       
       #If ($Row.NoSmartcardreq -notlike "x")
       {
       #Set-ADUser $Row.SamAccountname -Replace @{userAccountControl = "262656"} -Server $DCTieto
       }

    }

# ====== Account typ V =======================================================================================================    
    
if ($Row | Where-Object { ($_.accounttype -like "V")  })
 
    {
       # Create User Variable
       $Users = $Row.Samaccountname
              
       # Move users from DMZ to Tieto OU Script (Steg 1)
       #D:\Powershell\Stockholms_Stad\Move_Users_To_UsersOU.ps1

       # Set and clear Attributes
       #D:\Powershell\Stockholms_Stad\Set-Attributes.ps1

       # Add users to Application groups
       #D:\Powershell\Stockholms_Stad\AddTo_AppsGroups.ps1

       # Add Users to Groups that all users should have
       #D:\Powershell\Stockholms_Stad\Add_users_to_Groups_all_Users.ps1

       # Groupe translation script for adding users from HCL to Tieto groups
       D:\Powershell\Stockholms_Stad\If_In_GroupA_Add_To_GroupeB_rev1.ps1

       # Shared Folder
       #D:\Powershell\Stockholms_Stad\Move_SharedFolders_n_Groups.ps1

       # Set User complet in Exchange
       #Set-MoveRequest -Identity $Users -CompleteAfter $dateComplete -DomainController $DCTieto #-WhatIf
       
       #Set-ADUser $Row.SamAccountname -Replace @{userAccountControl = "514"} -Server $DCTieto
      
    }

    
# ====== Account typ L ===================================================================================================        
     
if ($Row | Where-Object { ($_.accounttype -like "L") })
 
    {
       # Create User Variable
       $Users = $Row.Samaccountname
             
       # Move users from DMZ to Tieto OU Script (Steg 1)
       #D:\Powershell\Stockholms_Stad\Move_Users_To_UsersOU.ps1

       # Set and clear Attributes
       #D:\Powershell\Stockholms_Stad\Set-Attributes.ps1

       # Add users to Application groups
       #D:\Powershell\Stockholms_Stad\AddTo_AppsGroups.ps1

       # Add Users to Groups that all users should have
       #D:\Powershell\Stockholms_Stad\Add_users_to_Groups_all_Users.ps1

       # Groupe translation script for adding users from HCL to Tieto groups
       D:\Powershell\Stockholms_Stad\If_In_GroupA_Add_To_GroupeB_rev1.ps1

       # Shared Folder
       #D:\Powershell\Stockholms_Stad\Move_SharedFolders_n_Groups.ps1
       
       # Set User complet in Exchange
       #Set-MoveRequest -Identity $Users -CompleteAfter $dateComplete -DomainController $DCTieto #-WhatIf

       # Set EmployeeType from l to k (Account will be enabled if we do this)
       #Set-ADUser $Row.SamAccountname -Replace @{employeeType = "k"} -Server $DCTieto

       #If ($Row.NoSmartcardreq -notlike "x")
       {
       #Set-ADUser $Row.SamAccountname -Replace @{userAccountControl = "262656"} -Server $DCTieto
       }
    }

# ====== Account typ O ===================================================================================================

if ($Row | Where-Object { ($_.accounttype -like "O") })
 
    {
       # Create User Variable
       $Users = $Row.Samaccountname
             
       # Move users from DMZ to Tieto OU Script (Steg 1)
       #D:\Powershell\Stockholms_Stad\Move_Users_To_UsersOU.ps1

       # Set and clear Attributes
       #D:\Powershell\Stockholms_Stad\Set-Attributes.ps1

       # Add users to Application groups
       #D:\Powershell\Stockholms_Stad\AddTo_AppsGroups.ps1

       # Add Users to Groups that all users should have
       #D:\Powershell\Stockholms_Stad\Add_users_to_Groups_all_Users.ps1

       # Groupe translation script for adding users from HCL to Tieto groups
       D:\Powershell\Stockholms_Stad\If_In_GroupA_Add_To_GroupeB_rev1.ps1

       # Shared Folder
       #D:\Powershell\Stockholms_Stad\Move_SharedFolders_n_Groups.ps1
       
       # Set User complet in Exchange
       #Set-MoveRequest -Identity $Users -CompleteAfter $dateComplete -DomainController $DCTieto #-WhatIf

       #If ($Row.NoSmartcardreq -notlike "x")
       {
       #Set-ADUser $Row.SamAccountname -Replace @{userAccountControl = "262656"} -Server $DCTieto
       }

     }   

<# ====== Account typ M ===================================================================================================

if ($Row | Where-Object { ($_.accounttype -like "M") })
 
    {
       # Create User Variable
       $Users = $Row.Samaccountname
             
       # Move users from DMZ to Tieto OU Script (Steg 1)
       D:\Powershell\Stockholms_Stad\Move_Users_To_UsersOU.ps1

       # Set and clear Attributes
       D:\Powershell\Stockholms_Stad\Set-Attributes.ps1

       # Add users to Application groups
       #D:\Powershell\Stockholms_Stad\AddTo_AppsGroups.ps1

       # Add Users to Groups that all users should have
       D:\Powershell\Stockholms_Stad\Add_users_to_Groups_Accounttype_M.ps1

       # Set employeeType to m
       Set-ADUser $User -Replace @{employeeType = "m"} -Server $DCTieto
              
       # Set User complet in Exchange
       Set-MoveRequest -Identity $Users -CompleteAfter $dateComplete -DomainController $DCTieto #-WhatIf

       

     } #>

       
}

#=== Close Exchange Session ===========================================================================================================
Remove-PSSession $session

#=== Add computers to Appgroups =======================================================================================================
D:\Powershell\Stockholms_Stad\AddTo_AppsGroups_Computers.ps1

#=== Stop Transcript ==================================================================================================================
Stop-Transcript

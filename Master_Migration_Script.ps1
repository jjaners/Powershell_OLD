# Master script to do everything sequentially

# UsersList to Run
$Users = Import-Csv -Header Samaccountname -LiteralPath D:\PSInData\Users-Migration\Migration_test.csv


# Move users to the DMZ Script and adding smartcardlogin
#D:\Powershell\Stockholms_Stad\Move_Users_To_DMZ.ps1

# Move users from DMZ to Tieto OU Script (Steg 1)
D:\Powershell\Stockholms_Stad\Move_Users_OU.ps1

# Set and clear Attributes
D:\Powershell\Stockholms_Stad\Set-Attributes.ps1

# Add users to Application groups (lägg till grupper från steg 2)
D:\Powershell\Stockholms_Stad\AddTo_AppsGroups.ps1

# Add Users to Groups that all users should have
D:\Powershell\Stockholms_Stad\Add_users_to_Groups_all_Users.ps1

# move Shared folders when owner moves 
#D:\Powershell\Stockholms_Stad\Move_SharedFolders_n_Groups.ps1

# Groupe translation script for adding users from HCL to Tieto groups
D:\Powershell\Stockholms_Stad\If_In_GroupA_Add_To_GroupeB_rev1.ps1

# Create User Print share
#D:\Powershell\Stockholms_Stad\Create_User_Print_share.ps1

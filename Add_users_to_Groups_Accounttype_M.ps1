
# Variables
#$DCTieto = "wsdc003.ad.stockholm.se"

# Add users to groups
#$Users = Import-Csv D:\PSInData\Users-Migration\Migration_test.csv

foreach ($User in $Users)
{
    #Add-ADGroupMember -Identity "sec-CoS-VDB-App-FJARR" -Members $User
    Add-ADGroupMember -Identity "Tieto Readers" -Members $User
    Add-ADGroupMember -Identity "Cos Readers" -Members $User
    #Add-ADGroupMember -Identity "Role-T1-HCPaw-production" -Members $User
    #Add-ADGroupMember -Identity "MobileIron-All-Users" -Members $User
    #Add-ADGroupMember -Identity "sec-T0-Deny-All-HomeFolders-HCL" -Members $User
    
}
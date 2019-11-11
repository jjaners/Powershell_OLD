# Move users from DMZ to CoS OU

#$data = Import-Csv -Header Samaccountname, Groupname1, Groupname2 -Delimiter ";" -LiteralPath D:\Powershell\InPut_Data\Test_Examplel.csv

$Users = Import-Csv -Header Samaccountname -LiteralPath "D:\powershell\InPut_Data\Samaccountname.csv"

#$Users = $data.Samaccountname | select -Skip 1
#$GroupS1 = $data.Groupname1 | select -Skip 1
#$GroupS2 = $data.Groupname2 | select -Skip 1

foreach ($User in $Users)
{
    $DN = Get-ADUser $user -Properties distinguishedname | select -ExcludeProperty distinguishedname
    
    # Move to Users_JJ
    Move-ADObject -Identity "$DN" -TargetPath "OU=Users_JJ,OU=Test_JJ,OU=STHLM,DC=ds,DC=stockholm,DC=se" #-TargetServer "WSDC001.ds.stockholm.se"
    # Move to Users_JJ_2
    #Move-ADObject -Identity "$DN" -TargetPath "OU=Users_JJ_2,OU=Test_JJ,OU=STHLM,DC=ds,DC=stockholm,DC=se"

    # Check if in groupA then add to groupB
    # (D:\Powershell\If_In_GroupA_Add_To_GroupeB_rev1.ps1)
    
    # Add to Application groups
    # (D:\Powershell\AddTo_AppsGroups.ps1)
        
    #Out-String "$DN"

}

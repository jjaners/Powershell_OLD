# Move users from DMZ to CoS OU

#$data = Import-Csv -Header Samaccountname, Groupname1, Groupname2 -Delimiter ";" -LiteralPath D:\Powershell\InPut_Data\Test_Examplel.csv
$DCTieto = "wsdc003.ad.stockholm.se"
#$Users = Import-Csv -Header Samaccountname -LiteralPath D:\PSInData\Users-Migration\Migration_test.csv

#$Users = $data.Samaccountname | select -Skip 1
#$GroupS1 = $data.Groupname1 | select -Skip 1
#$GroupS2 = $data.Groupname2 | select -Skip 1

foreach ($User in $Users)
{
    #$UserSam = Get-ADUser -Identity $user | select samaccountname
    $DN = Get-ADUser $user -Properties distinguishedname -Server $DCTieto | select -ExpandProperty distinguishedname
    
    # Move to Users_JJ
    Move-ADObject -Identity "$DN" -TargetPath "OU=Users,OU=CoS,DC=ad,DC=stockholm,DC=se" -Server $DCTieto
    # Move to Users_JJ_2
    #Move-ADObject -Identity "$DN" -TargetPath "OU=Users_JJ_2,OU=Test_JJ,OU=STHLM,DC=ds,DC=stockholm,DC=se"

    # Check if in groupA then add to groupB
    # (D:\Powershell\If_In_GroupA_Add_To_GroupeB_rev1.ps1)
    
    # Add to Application groups
    # (D:\Powershell\AddTo_AppsGroups.ps1)
        
    #Out-String "$DN"

}

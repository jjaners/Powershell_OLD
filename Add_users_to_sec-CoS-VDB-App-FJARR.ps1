
# Add users to sec-CoS-VDB-App-FJARR
$Users = Import-Csv "D:\Powershell\InPut_Data\Samacountnames.csv"

foreach ($User in $Users)
{
    Add-ADGroupMember -Identity "sec-CoS-VDB-App-FJARR" -Member $User


}
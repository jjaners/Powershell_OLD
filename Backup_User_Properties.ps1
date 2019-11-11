# === Get all user attributes for all users in COS OU ===
<#
$date = get-date -Format yyyyMMdd

$CosUsers = Get-ADUser -SearchBase "OU=Users,OU=CoS,DC=ad,DC=stockholm,DC=se" -filter * -Properties *

$CosUsers | export-csv "D:\Backup\User_Properties_Backup\Cos_User_properties_Backup_$date.csv" -NoClobber -Encoding UTF8
#>


# === Get all Computer attributes for all users in COS OU ===

$date = get-date -Format yyyyMMdd

$CosUsers = Get-ADUser -SearchBase "OU=Users,OU=CoS,DC=ad,DC=stockholm,DC=se" -filter * -Properties * #name | select name #| select -First 5
$Result = @()
foreach ($CS in $CosUsers)
{
    $Result += $CS
    #(Get-ADGroup $CS -Properties * | select -Property *)

}


$Result | export-csv "D:\Backup\User_Properties_Backup\Cos_User_properties_Backup_$date.csv" -NoClobber -Encoding UTF8
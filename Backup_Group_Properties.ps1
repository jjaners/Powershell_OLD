# === Get all Computer attributes for all users in COS OU ===

$date = get-date -Format yyyyMMdd

$CosGroups = Get-ADGroup -SearchBase "OU=ServiceNowGroups,OU=Groups,OU=CoS,DC=ad,DC=stockholm,DC=se " -filter * -Properties * #name | select name #| select -First 5
$Result = @()
foreach ($CG in $CosGroups)
{
    $Result += $CG
    #(Get-ADGroup $CS -Properties * | select -Property *)

}


$Result | export-csv "D:\Backup\Computers_Properties_Backup\Cos_Groups_properties_Backup_$date.csv" -NoClobber -Encoding UTF8
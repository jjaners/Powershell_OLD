
Start-Transcript -Path "D:\Logs\UserAccountControl_log_20190818.txt"

#=== Variables ==================
#$date = read-host "Enter date in format yyyyMMdd"
$DCTieto = "wsdc003.ad.stockholm.se"
#$Users = Import-Csv "D:\PSInData\Users-Migration\BaseFile\combined_$date.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate -Delimiter "," | select -Skip 1
$Masterlist = Import-Csv "D:\PSInData\Users-Migration\Skolfastigheter_SISAB-20190818.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate -Delimiter ";" | select -Skip 1
$users = $Masterlist.samaccountname

#$result = @()
foreach ($user in $Users)
{
    $U = Get-ADUser $user -Properties SamAccountName,userAccountControl #| select -ExpandProperty SamAccountName
    #$U = (Get-ADUser $user -Properties * | select SamAccountName)
    if ($U.userAccountControl -like "262656")
    {
        #Set-ADUser $User -Replace @{userAccountControl = "512"} -Server $DCTieto -Verbose -WhatIf
        #write-host "$U"
        Write-Host $user $U.userAccountControl -ForegroundColor Green
    }
    else
    {
        Write-Host $user $U.userAccountControl -ForegroundColor red
    }
            
    #$Result += $U
}

Stop-Transcript
#$result
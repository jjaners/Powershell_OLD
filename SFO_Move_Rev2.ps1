# === Set Date ===
#$date = Read-Host "Input date in format yyyyMMdd"

#=== Start Transcript ======================================================
#$TransDate = get-date -Format yyyyMMddHHmm
Start-Transcript -Path "D:\Logs\SharedFolders\SFO_Transcript_$Date.txt" -NoClobber

#=== Verbose pref ===
$VerbosePreference = "SilentlyContinue"
#=== Import Module ===
Import-Module ActiveDirectory

#$Users=import-csv -Path D:\Mikael\Shared-Folder-Mig\Test-To-DS.csv -Delimiter ";"
$Users = Import-Csv "D:\PSInData\Users-Migration\BaseFile\combined_$Date.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate -Delimiter "," | select -Skip 1


$TargetPathGroups = "OU=Storage,OU=ServiceNowGroups,OU=Groups,OU=CoS,DC=ad,DC=stockholm,DC=se"
$TargetPathSharedFolders = "OU=SharedFolders,OU=CoS,DC=ad,DC=stockholm,DC=se"
#$DCTieto = "WSDC007.ds.stockholm.se"
$DCTieto = "wsdc003.ad.stockholm.se"

foreach ($user in $Users){

$DN=Get-ADUser $user.SamAccountName | select -ExpandProperty DistinguishedName
$OwnerOfSharedFolders = Get-ADObject -Filter {(managedBy -like $DN) -and (objectClass -eq "volume")} -SearchBase "OU=SF,OU=Storage,OU=CS,DC=ad,DC=stockholm,DC=se" -SearchScope OneLevel -Server $DCTieto
    
    foreach ($OwnerOfSharedFolder in $OwnerOfSharedFolders){
    #write-host "$OwnerOfSharedFolder"} }
    
    $GroupA = $OwnerOfSharedFolder.Name + "-A"
    $DNGroupA = Get-ADGroup $GroupA -Server $DCTieto | select -ExpandProperty DistinguishedName
    $GroupR = $OwnerOfSharedFolder.Name + "-R"
    $DNGroupR = Get-ADGroup $GroupR -Server $DCTieto | select -ExpandProperty DistinguishedName
    $GroupX = $OwnerOfSharedFolder.Name + "-X"
    $DNGroupX = Get-ADGroup $GroupX -Server $DCTieto | select -ExpandProperty DistinguishedName
    $SFName = $OwnerOfSharedFolder.DistinguishedName
    #write-host "$GroupA,$GroupR,$GroupX"} }
         
    Move-ADObject $DNGroupA -TargetPath $TargetPathGroups -Server $DCTieto #-WhatIf
    Write-host $DNGroupA
    Move-ADObject $DNGroupR -TargetPath $TargetPathGroups -Server $DCTieto #-WhatIf
    Write-Host $DNGroupR
    Move-ADObject $DNGroupX -TargetPath $TargetPathGroups -Server $DCTieto #-WhatIf
    Write-Host $DNGroupX
    Move-ADObject $SFName -TargetPath $TargetPathSharedFolders -Server $DCTieto #-WhatIf
    
    Write-Host $SFName
    #$SFName | Export-Csv D:\Logs\SFO_Checklist_$date.csv
    } 
}

#=== Stop Transcript =============================================================
Stop-Transcript
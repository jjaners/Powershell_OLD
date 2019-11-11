# Exchange finnish mailbox move

#Write-Host "NOTE! Please check Date variable before continueing" -ForegroundColor Cyan
#Read-Host -Prompt "Press any key to continue..."

#=== Variables ==================
#$date = read-host "Enter date in format yyyyMMdd"
$DCTieto = "wsdc003.ad.stockholm.se"
$Masterlist = Import-Csv "D:\PSInData\Users-Migration\BaseFile\combined_$date.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate -Delimiter "," | select -Skip 1
#$Masterlist = Import-Csv "D:\PSInData\Users-Migration\Extra\extra-20190610.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate -Delimiter ";" | select -Skip 1
$users = $Masterlist.samaccountname

#=== Credentials =====================================================================================================================
$User = "crSCRIPT-Migration"
$PWord = ConvertTo-SecureString "YrAddHyxZ5m8VvSmZdnQmFFWu64ba4%47dWCrBjPn48Ce8WP" -AsPlainText -Force #"YrAddHyxZ5m8VvSmZdnQmFFWu64ba4%47dWCrBjPn48Ce8WP"
$Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $User, $PWord

$SessionOpt = New-PSSessionOption -SkipCACheck:$true -SkipCNCheck:$true -SkipRevocationCheck:$true
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://wsex001/powershell/ -Credential $Credential -SessionOption $SessionOpt
Import-PSSession $Session




$DCTieto      = "wsdc003.ad.stockholm.se"
$dateshort    = get-date -Format "MM/dd/yyyy"
$Time         = " 07:00:00 PM"
$dateComplete = $dateshort + $Time

foreach ($Muser in $users){

Set-MoveRequest -Identity $Muser -CompleteAfter $dateComplete -DomainController $DCTieto #-WhatIf
}


<#
foreach ($Muser in $users){

get-MoveRequest -Identity $Muser -DomainController $DCTieto | select DistinguishedName,Status
}

#>

Get-PSSession | Remove-PSSession
#Remove-PSSession $Session
exit
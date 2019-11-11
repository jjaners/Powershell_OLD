# === Date Variables ===
$Date = get-date -Format yyyyMMdd

#=== Start Transcript ================================================================================================================
$TransDate = get-date -Format yyyyMMddHHmm
Start-Transcript -Path "D:\Logs\Mig_Transcript-5_$TransDate.txt" -NoClobber

# === Check if combined file exists ===
$testpath = Test-Path D:\PSInData\Users-Migration\BaseFile\combined_$date.csv

if ($testpath -eq $true)
{
    Write-Host "  combined_$date.csv exists" -ForegroundColor Green

    
#=== Move the user from HCL ==============================================================================================================

    #=== Credentials =====================================================================================================================
    $User = "crSCRIPT-Migration"
    $PWord = ConvertTo-SecureString "YrAddHyxZ5m8VvSmZdnQmFFWu64ba4%47dWCrBjPn48Ce8WP" -AsPlainText -Force #"YrAddHyxZ5m8VvSmZdnQmFFWu64ba4%47dWCrBjPn48Ce8WP"
    $Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $User, $PWord

    #=== Connect to WebService ===========================================================================================================
    $Pxy = New-WebServiceProxy -Uri "http://ws00970.ad.stockholm.se/HCL.Sthlm.MigrationServices.Service/MigrationServices.svc" -Credential $Credential -Namespace WsProxy

    #=== Load array for user that should move ============================================================================================
    $SamaccountList = Import-Csv -Path "D:\PSInData\Users-Migration\BaseFile\combined_$date.csv" -Delimiter ","

    #=== Move many user ==================================================================================================================
    $ToDayDate = Get-Date -Format "yyyyMMdd-HHmm"
    $Batchname = "Tieto-Prod-$ToDayDate"
    $Results = @()


    foreach ($User in $SamaccountList){
    
        $MigUser = $user.SamAccountname

        $results01 = $pxy.MigrateUser($MigUser, $null, $Batchname, $true, $true)
    
        $Results += $results01
    }

    #=== Exchange session ================================================================================================================
        $session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://WSC01208-N1/PowerShell/ -Credential $Credential
        Import-PSSession $Session -DisableNameChecking 

    # === Set MailBox Quotas =============================================================================================================
    foreach ($User in $SamaccountList)
    {
        set-mailbox -Identity $User.SamAccountName -IssueWarningQuota Unlimited -ProhibitSendQuota Unlimited -ProhibitSendReceiveQuota Unlimited -UseDatabaseQuotaDefaults $false    
    }

    #=== Close Exchange Session ===========================================================================================================
        Remove-PSSession $session

    #=== Create Log =======================================================================================================================
    $Results | export-csv -Path D:\Logs\MigLog-$Batchname.csv -Delimiter ";" -Encoding UTF8 -NoTypeInformation

    #=== Backup User Properties ===========================================================================================================
    $backupfile = "UserPropertiesBackup_" + "$Batchname" + ".xml"
    $FormatEnumerationLimit = -1
    $SamaccountList | % {Get-ADUser $_.samaccountname -Properties *} | Export-Clixml -Path D:\Logs\UserPropertiesBackup\$backupfile

    Start-Sleep -Seconds 5

    # === Send GO mail to Homefolder crew ===
    Send-MailMessage -From 'AD-Team <AD.NoReply@Tieto.com>' -To 'Jack_Tieto <ext.jack.janers@tieto.com>' -Subject "$date Combine exists, Users moved to DMZ" -Body "$date `n `nCombine exists, Users moved to DMZ"  -SmtpServer 'extrelay.stockholm.se' -Port '25'
    #   -Cc 'Bengt Jonsson <ext.bengt.jonsson@tieto.com>'

    # === Move files used for combine file ===
    $FilesShare = "\\WSADMGMT01\PSInData\Users-Migration\"
    $Move = Get-ChildItem -Path $FilesShare "*$date*" | Select-Object -ExpandProperty FullName
    $move | move-item -Destination D:\PSInData\Users-Migration\Done


}
else
{
    Write-Host "  Createing combined_$date.csv ... .. ." -ForegroundColor DarkYellow

    # === Combine files with the same date ===============================================================================================

    $FilesShare = "\\WSADMGMT01\PSInData\Users-Migration\"
    $Combine = Get-ChildItem -Path $FilesShare "*$date*"`
    | Select-Object -ExpandProperty FullName | Import-Csv -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate, SthlmFakturaRef -Delimiter ';' | select -Skip 1 `
    | Export-Csv "D:\PSInData\Users-Migration\BaseFile\combined_$date.csv" -Delimiter ',' -NoTypeInformation -NoClobber -Append

    Write-Host "  combined_$date.csv created" -ForegroundColor DarkGreen

#=== Move the user from HCL ==============================================================================================================

    #=== Credentials =====================================================================================================================
    $User = "crSCRIPT-Migration"
    $PWord = ConvertTo-SecureString "YrAddHyxZ5m8VvSmZdnQmFFWu64ba4%47dWCrBjPn48Ce8WP" -AsPlainText -Force #"YrAddHyxZ5m8VvSmZdnQmFFWu64ba4%47dWCrBjPn48Ce8WP"
    $Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $User, $PWord

    #=== Connect to WebService ===========================================================================================================
    $Pxy = New-WebServiceProxy -Uri "http://ws00970.ad.stockholm.se/HCL.Sthlm.MigrationServices.Service/MigrationServices.svc" -Credential $Credential -Namespace WsProxy

    #=== Load array for user that should move ============================================================================================
    $SamaccountList = Import-Csv -Path "D:\PSInData\Users-Migration\BaseFile\combined_$date.csv" -Delimiter ","

    #=== Move many user ==================================================================================================================
    $ToDayDate = Get-Date -Format "yyyyMMdd-HHmm"
    $Batchname = "Tieto-Prod-$ToDayDate"
    $Results = @()


    foreach ($User in $SamaccountList){
    
        $MigUser = $user.SamAccountname

        $results01 = $pxy.MigrateUser($MigUser, $null, $Batchname, $true, $true)
    
        $Results += $results01
    }

    #=== Exchange session ================================================================================================================
        $session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://WSC01208-N1/PowerShell/ -Credential $Credential
        Import-PSSession $Session -DisableNameChecking 

    # === Set MailBox Quotas =============================================================================================================
    foreach ($User in $SamaccountList)
    {
        set-mailbox -Identity $User.SamAccountName -IssueWarningQuota Unlimited -ProhibitSendQuota Unlimited -ProhibitSendReceiveQuota Unlimited -UseDatabaseQuotaDefaults $false    
    }

    #=== Close Exchange Session ===========================================================================================================
        Remove-PSSession $session

    #=== Create Log =======================================================================================================================
    $Results | export-csv -Path D:\Logs\MigLog-$Batchname.csv -Delimiter ";" -Encoding UTF8 -NoTypeInformation

    #=== Backup User Properties ===========================================================================================================
    $backupfile = "UserPropertiesBackup_" + "$Batchname" + ".xml"
    $FormatEnumerationLimit = -1
    $SamaccountList | % {Get-ADUser $_.samaccountname -Properties *} | Export-Clixml -Path D:\Logs\UserPropertiesBackup\$backupfile
    
    Start-Sleep -Seconds 5

    # === Send GO mail to Homefolder crew ===
    Send-MailMessage -From 'AD-Team <AD.NoReplay@Tieto.com>' -To 'Jack_Tieto <ext.jack.janers@tieto.com>' -Subject "$date Combine created, Users moved to DMZ" -Body "$date `n `nCombine created, Users moved to DMZ"  -SmtpServer 'extrelay.stockholm.se' -Port '25'
    #  -Cc '<jack.janers@centricsweden.se>'

    # === Move files used for combine file ===
    $FilesShare = "\\WSADMGMT01\PSInData\Users-Migration\"
    $Move = Get-ChildItem -Path $FilesShare "*$date*" | Select-Object -ExpandProperty FullName
    $move | move-item -Destination D:\PSInData\Users-Migration\Done

}

#=== Stop Transcript ==================================================================================================================
Stop-Transcript


# === DL Lists ===

#=== Credentials =====================================================================================================================
$User = "crSCRIPT-Migration"
$PWord = ConvertTo-SecureString "YrAddHyxZ5m8VvSmZdnQmFFWu64ba4%47dWCrBjPn48Ce8WP" -AsPlainText -Force #"YrAddHyxZ5m8VvSmZdnQmFFWu64ba4%47dWCrBjPn48Ce8WP"
$Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $User, $PWord

#=== Connect to WebService ===========================================================================================================
$Pxy = New-WebServiceProxy -Uri "http://ws00970.ad.stockholm.se/HCL.Sthlm.MigrationServices.Service/MigrationServices.svc" -Credential $Credential -Namespace WsProxy

#Move DL-Groups or contacts user object through web service
#Import users.
#$User="AB67959"
# === Browse for file funtionality ===
    $InitialDirectory = "D:\PSInData\DL_Groups\"
    param(

        [Parameter(ValueFromPipeline=$true,HelpMessage="Enter CSV path(s)")]
        [String[]]$Path = $null
    )

    if($Path -eq $null) {

        Add-Type -AssemblyName System.Windows.Forms

        $Dialog = New-Object System.Windows.Forms.OpenFileDialog
        $Dialog.InitialDirectory = "$InitialDirectory"
        $Dialog.Title = "Select CSV File(s)"
        $Dialog.Filter = "CSV File(s)|*.csv"        
        $Dialog.Multiselect=$true
        $Result = $Dialog.ShowDialog()

        if($Result -eq 'OK') {

            Try {
    
                $Path = $Dialog.FileNames
            }

            Catch {

                $Path = $null
                Break
            }
        }

        else {

            #Shows upon cancellation of Save Menu
            Write-Host -ForegroundColor Yellow "Notice: No file(s) selected."
            Break
        }
    }

#$MoveDLGroups = import-csv -Path 'C:\Scripts\mikael\Move DL Groups and Contacts\DL-Groups\DL-Groups-20191004.csv' -Delimiter ";"
$MoveDLGroups = import-csv -Path $Path -Delimiter ";"

#Envirement settings
#Comment are the same. It just that we need to have something.
$Comment= "GSIT2.0"
#$DCTieto = "wsdc003.ad.stockholm.se"
$DCTieto = "ws00002.ad.stockholm.se"

$ToDayDate = Get-Date -Format "yyyyMMdd-HHmm"
$Batchname = "Move_DL_Groups_Log_$ToDayDate.csv"

#Call out of HCL webservice

$Results = @()
foreach ($MoveDLGroup in $MoveDLGroups){
$samaccountname = $MoveDLGroup.SamAccountName

$results01 = $Pxy.MigrateMsxResource($samaccountname,$Comment)

$Results += $results01
}

#$Results | Out-GridView
#$Results | export-csv -Path "C:\Scripts\Mikael\Move DL Groups and Contacts\DL-Groups\Log\$Batchname" -Delimiter ";" -Encoding UTF8 -NoTypeInformation
$Results | export-csv -Path "D:\Logs\DL_Groups\$Batchname" -Delimiter ";" -Encoding UTF8 -NoTypeInformation

start-sleep -Seconds 300
#Read-Host -Prompt "Press Enter to proceed"
##### STOP HERE AND WAITE FORE THE OBJECT IN DMZ #################

Write-Host "Number in file "$MoveDLGroups.count"st"
Write-Host "-------------------------------------------------------------"
write-host "NUmber of MoveDLGroups in DMZ from File"($MoveDLGroups | %{Get-ADGroup $_.samaccountname -Server $DCTieto} | where DistinguishedName -Like "*OU=Groups,OU=Tieto,OU=DMZ,DC=ad,DC=stockholm,DC=se").count""

#Move Object to User OU
#$DCTieto = "wsdc003.ad.stockholm.se"
$GroupMove = $MoveDLGroups.samaccountname

foreach ($Group in $GroupMove)
{
    #Get distinguishedname
    $DN = Get-ADGroup $Group -Properties distinguishedname -Server $DCTieto | select -ExpandProperty distinguishedname
    
    # Move to Groups to 
    Move-ADObject -Identity "$DN" -TargetPath "OU=ServiceNowGroups,OU=Groups,OU=CoS,DC=ad,DC=stockholm,DC=se" -Server $DCTieto
    
}

Move-Item $path -Destination "D:\PSInData\DL_Groups\Done\"
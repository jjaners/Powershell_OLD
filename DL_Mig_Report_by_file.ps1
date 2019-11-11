
$date = get-date -Format yyyyMMdd_HHmm

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


$Results = @()
foreach ($MoveDLGroup in $MoveDLGroups)
{
    #$samaccountname = $MoveDLGroup.SamAccountName

    $results01 = Get-ADGroup $MoveDLGroup.samaccountname -Properties Name, DistinguishedName | select Name, DistinguishedName
    #$Pxy.MigrateMsxResource($samaccountname,$Comment)

    $Results += $results01
}

#$Results | Out-GridView
#$Results | export-csv -Path "C:\Scripts\Mikael\Move DL Groups and Contacts\DL-Groups\Log\$Batchname" -Delimiter ";" -Encoding UTF8 -NoTypeInformation
$Results | export-csv -Path "D:\Logs\DL_Groups\DL_Mig_Report_$date.csv" -Delimiter ";" -Encoding UTF8 -NoTypeInformation
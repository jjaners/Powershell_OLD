# === Set SthlmFakturaRef ===

# === Variable ===
$date = get-date -Format yyyyMMdd

# === MessageBox ===
Add-Type -AssemblyName PresentationFramework
$msgBoxInput = [System.Windows.MessageBox]::Show('Select input CSV containing only samaccountnames.','File Selection info','OKCancel','Info')
#[System.Windows.MessageBox]::Show('Select input CSV containing only samaccountnames.')

# === Browse for file funtionality ===
  switch  ($msgBoxInput) {

  'OK' {    
    
    $InitialDirectory = "D:\PSInData\Users-Migration\"
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

$Masterlist = Import-Csv "$Path" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate, SthlmFakturaRef -Delimiter "," | select -Skip 1

$users = $Masterlist

$Results = @()
foreach ($User in $Users)
{

    $U = $user.SamAccountName
    #$X = $User.NoSmartcardreq
    #$SthlmFakturaRef = $User.SthlmFakturaRef

    $Result1 = Get-ADUser $U -Properties SamAccountName,SthlmFakturaRef | select SamAccountName,SthlmFakturaRef

    $Results += $Result1

}
$Results | export-csv D:\Logs\Temp\SthlmFakturaRef_Report_$date.csv

  }

  'Cancel' {

  Write-Host "Canceled no file selected" -ForegroundColor Yellow

  }

 }
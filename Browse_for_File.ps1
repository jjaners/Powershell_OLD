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

Get-Content $path
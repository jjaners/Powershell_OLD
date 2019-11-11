# === Set SthlmFakturaRef ===

# === MessageBox ===
Add-Type -AssemblyNamePresentationFramework
[System.Windows.MessageBox]::Show('Select input CSV containing only samaccountnames.','File Selection info','OK','Info')
#[System.Windows.MessageBox]::Show('Select input CSV containing only samaccountnames.')

# === Browse for file funtionality ===
    $InitialDirectory = "D:\PSInData\Users-Migration\"
    param(

        [Parameter(ValueFromPipeline=$true,HelpMessage="Enter CSV path(s)")]
        [String[]]$Path = $null
    )

    $InitialDirectory = "D:\PSInData\Users-Migration\"

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

#$result = @()
foreach ($User in $Users)
{
    $U = $user.SamAccountName
    $X = $User.NoSmartcardreq
    $SthlmFakturaRef = $User.SthlmFakturaRef
    <#
    $result += $U
    $result += $X
    $result += $SthlmFakturaRef
    $result += Get-ADUser $U -Properties SthlmFakturaRef | select -ExpandProperty SthlmFakturaRef
    #>
    #Set-ADUser $U -Replace @{SthlmFakturaRef = "$SthlmFakturaRef"} -Server $DCTieto
    
    If ($SthlmFakturaRef -NotMatch "^\d+$") #-notlike $Null
        {
            Set-ADUser $U -Clear SthlmFakturaRef -Server $DCTieto #-WhatIf
            #Write-Host "$U has $SthlmFakturaRef" -BackgroundColor red
        }
    else
        {
            Set-ADUser $U -Replace @{SthlmFakturaRef = "$SthlmFakturaRef"} -Server $DCTieto #-WhatIf
            #Write-Host "$U has $SthlmFakturaRef" -BackgroundColor Green
        }
    
}
#$result | ft -AutoSize
<#
In regex \d is the check for digits

\d* checks for 0 to infinite digits

\d? Checks for 0 to 1 digit

\d{0,5} checks for 0 to 5 digits

\d+ checks for 1 to infinite digits

^ is the beggining of a line

$ is the end of a line

So

^\d+$ will check for 1 or more digits from the beginning to the end of the line and only digits. Any other symbol will break the connection from beginning to end and not be found.
#>
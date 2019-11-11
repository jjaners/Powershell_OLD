#================================
# Set Attributes #
#================================

#Write-Host "NOTE! Please check Date variable before continueing" -ForegroundColor Cyan
#Read-Host -Prompt "Press any key to continue..."

#=== Variables ==================
$Date = Get-date -Format yyyyMMdd-HHmm
#$date = read-host "Enter date in format yyyyMMdd"
$DCTieto = "wsdc003.ad.stockholm.se"

    param(

        [Parameter(ValueFromPipeline=$true,HelpMessage="Enter CSV path(s)")]
        [String[]]$Path = $null
    )

    if($Path -eq $null) {

        Add-Type -AssemblyName System.Windows.Forms
        $InitialDirectory = "D:\PSInData\Temp\"
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



    #Get-Content $path


#$SharedMailboxesList = import-csv -Path "D:\PSInData\Users-Migration\Shared-Mailboxes\*Resurs*$date.csv" -Delimiter ";"
#$SharedMailboxesList = import-csv -Path $Path -Delimiter ";"

#$Masterlist = Import-Csv "D:\PSInData\Users-Migration\BaseFile\combined_$date.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate -Delimiter "," | select -Skip 1
$Masterlist = Import-Csv $Path -Header SamAccountname,Name,sthlmFakturaRef,sthlmForvaltningsNr,sthlmVerksamhetsId -Delimiter ";" | select -Skip 1

$users = $Masterlist #.samaccountname


foreach ($User in $Users)
{
    $U = $user.SamAccountName
    #$N = $User.Name
    #$SFR = $user.sthlmFakturaRef
    #$SFN = $User.sthlmForvaltningsNr
    #$SVI = $User.sthlmVerksamhetsId
    #Get-ADUser $U -Properties SamAccountname,Name,sthlmFakturaRef,sthlmForvaltningsNr,sthlmVerksamhetsId | select SamAccountname,Name,sthlmFakturaRef,sthlmForvaltningsNr,sthlmVerksamhetsId
    $Result = Get-ADUser $U -Properties SamAccountname,Name,sthlmFakturaRef,sthlmForvaltningsNr,sthlmVerksamhetsId | select SamAccountname,Name,sthlmFakturaRef,sthlmForvaltningsNr,sthlmVerksamhetsId
    $Result | Export-Csv D:\Logs\Set_Sthlm_Attributs_Log_$Date.csv -Append
    #Write-Host $U, $N, $SFR, $SFN, $SVI }
    
    # Set user attributes
    #set-aduser -Identity $U -Replace @{sthlmFakturaRef = "$SFR"} -Server $DCTieto
    #set-aduser -Identity $U -Replace @{sthlmForvaltningsNr = "$SFN"} -Server $DCTieto
    #set-aduser -Identity $U -Replace @{sthlmVerksamhetsId = "$SVI"} -Server $DCTieto

}

<#
foreach ($User in $Users)
{
    $U = $user.SamAccountName
    $N = $User.Name
    $SFR = $user.sthlmFakturaRef
    $SFN = $User.sthlmForvaltningsNr
    $SVI = $User.sthlmVerksamhetsId
    
    #Write-Host $U, $N, $SFR, $SFN, $SVI }
    
    # Set user attributes
    set-aduser -Identity $U -Replace @{sthlmFakturaRef = "$SFR"} -Server $DCTieto
    set-aduser -Identity $U -Replace @{sthlmForvaltningsNr = "$SFN"} -Server $DCTieto
    set-aduser -Identity $U -Replace @{sthlmVerksamhetsId = "$SVI"} -Server $DCTieto

}
#>
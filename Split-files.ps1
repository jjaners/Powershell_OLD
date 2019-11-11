# === Split FIles ===

# === Clear Variable ===
#Clear-Variable date

# === MessageBox ===

#Add-Type -AssemblyName PresentationFramework
#[System.Windows.MessageBox]::Show('Select input CSV to split in to files by date.','File Selection info','OK','Info')
#[System.Windows.MessageBox]::Show('Select input CSV containing only samaccountnames.')

# === Browse for file funtionality ===

    param(

        [Parameter(ValueFromPipeline=$true,HelpMessage="Enter CSV path(s)")]
        [String[]]$Path = $null
    )

    if($Path -eq $null) {

        Add-Type -AssemblyName System.Windows.Forms
        $InitialDirectory = "D:\PSInData\Users-Migration\Files_To_Split\"
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

$List = import-csv -path $Path -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate, SthlmFakturaRef  -Delimiter ";"
$FileNameChange = Get-ChildItem $path
# === Clean up filename ===
$OrganizationName = $FileNameChange.BaseName -replace " ","_" -replace "Å","a" -replace "Ö","o" -replace "Ä","a"

$Dates = $List | select -Unique usermovedate
$date = @()

# === Split file based on date ===
foreach ($date in $Dates){

$date01 = $Date
$SortedList = $List | Where-Object UserMoveDate -EQ $date.UserMoveDate

$DateObject = [datetime]::ParseExact($date.UserMoveDate,"yyyy-MM-dd",$null)
$AddOneDay = $DateObject.AddDays(0)
$DayValue = $AddOneDay.ToString("yyyyMMdd")
$Fileprefix = ".csv"
$FilePath = "D:\PSInData\Users-Migration\"
$FileName = "$OrganizationName-" + $DayValue + $Fileprefix
$FullFilePath = $FilePath + $FileName

$SortedList | export-csv -Path $FullFilePath -Encoding UTF8 -Delimiter ';' -NoTypeInformation

# === Remove Quotas ===
$RMQuota = Get-Content $FullFilePath
$RMQuota.Replace('"',"").TrimStart('"').TrimEnd('"') | Out-File $FullFilePath -Force -Confirm:$false

}

# === Move file after it is split up ===
Move-Item $Path -Destination "D:\PSInData\Users-Migration\Files_To_Split\Done\"
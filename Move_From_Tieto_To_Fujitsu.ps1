################### MOVE FROM TIETO TO FUJITSU #########################################

#Credentials to use.
$User = "crSCRIPT-Migration"
$PWord = ConvertTo-SecureString "YrAddHyxZ5m8VvSmZdnQmFFWu64ba4%47dWCrBjPn48Ce8WP" -AsPlainText -Force #"YrAddHyxZ5m8VvSmZdnQmFFWu64ba4%47dWCrBjPn48Ce8WP"
$Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $User, $PWord

$SessionOpt = New-PSSessionOption -SkipCACheck:$true -SkipCNCheck:$true -SkipRevocationCheck:$true
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://wsex001/powershell/ -Credential $Credential -SessionOption $SessionOpt
Import-PSSession $Session

# === Variables ===
$DCtieto = "wsdc003"
$database="MDB_WSC01210_013"

$InitialDirectory = "D:\PSInData\Contacts_Migration"
    param(

        [Parameter(ValueFromPipeline = $true, HelpMessage = "Enter CSV path(s)")]
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

$UserstoMove = import-csv -Path $Path -Delimiter ";"
#$UserstoMove="aa49171"

#Get-Mailbox -Database lonDB1 | New-MoveRequest -BatchName "lonDB1tolonDB2” -TargetDatabase lonDB2 -Priority High -BadItemLimit 50 –AcceptLargeDataLoss
foreach ($UsertoMove in $UserstoMove)
{
#remove old move requests
get-mailbox $UsertoMove | Remove-MoveRequest -Confirm:$false

#create move requests
New-MoveRequest -Identity $UsertoMove  -TargetDatabase $database -BadItemLimit 100 
-AcceptLargeDataLoss

#Check move requests.
Get-MoveRequest $UsertoMove
Get-MoveRequest $UsertoMove | Get-MoveRequestStatistics -DomainController $DCtieto

#Move the User object to Fujitsu
Get-ADUser $UsertoMove -Server $DCtieto | Move-ADObject -TargetPath "OU=Tieto,OU=Users,OU=Fujitsu,OU=DMZ,DC=ad,DC=stockholm,DC=se" -Server $DCtieto
Get-ADUser $UsertoMove -Server $DCtieto | select disting*

#Check database size
Get-MailboxDatabase -Status | sort name | select name,@{Name='DB Size (Gb)';Expression={$_.DatabaseSize.ToGb()}},@{Name='Available New Mbx Space Gb)';Expression={$_.AvailableNewMailboxSpace.ToGb()}}
Get-MailboxDatabase -Status | select ServerName,Name,DatabaseSize
}
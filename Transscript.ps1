

#Page_Load
Start-Transcript -path D:\powershell\PS_Results\Test_Log.txt -append -NoClobber -IncludeInvocationHeader

Get-ADUser -Filter * -SearchBase 'OU=Users,OU=CoS,DC=ad,DC=stockholm,DC=se' -Properties Samaccountname | select samaccountname

Stop-Transcript






$VerbosePreference = "Continue"
#$LogPath = Split-Path $MyInvocation.MyCommand.Path
$LogPath = "D:\Powershell\PS_Results\logs\"
Get-ChildItem "$LogPath\*.log" | Where LastWriteTime -LT (Get-Date).AddDays(-15) | Remove-Item -Confirm:$false
#$LogPathName = Join-Path -Path $LogPath -ChildPath "$($MyInvocation.MyCommand.Name)-$(Get-Date -Format 'MM-dd-yyyy').log"
$LogPathName = "$LogPath\Test_Log_$(get-date -f yyyy-MM-dd).Log"
Start-Transcript $LogPathName -Append

$data = Get-ADUser -Filter * -SearchBase 'OU=Users,OU=CoS,DC=ad,DC=stockholm,DC=se' -Properties Samaccountname | select samaccountname -Verbose
Write-Verbose "$(Get-Date): $data"

# at the end of the script just add:
Stop-Transcript


$data = Get-ADUser -Filter * -SearchBase 'OU=Users,OU=CoS,DC=ad,DC=stockholm,DC=se' -Properties Samaccountname | select samaccountname -Verbose | out-file "D:\Powershell\PS_Results\logs\OutFile_Log.log"
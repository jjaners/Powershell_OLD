# logging function

$VerbosePreference = "Continue"
$LogPath = Split-Path $MyInvocation.MyCommand.Path
Get-ChildItem "$LogPath\*.log" | Where LastWriteTime -LT (Get-Date).AddDays(-15) | Remove-Item -Confirm:$false
$LogPathName = Join-Path -Path $LogPath -ChildPath "$($MyInvocation.MyCommand.Name)-$(Get-Date -Format 'MM-dd-yyyy').log"
Start-Transcript $LogPathName -Append


Write-Verbose "$(Get-Date): my log information here..."


# at the end of the script just add:
Stop-Transcript




# Alernativ
<#
Page_Load
Start-Transcript -path D:\Logs\Test_Log.txt -append -NoClobber -IncludeInvocationHeader
$GS = get-service
foreach ($item in $GS)
{
    Write-Verbose "$(Get-Date): $item"
}


Stop-Transcript

#>

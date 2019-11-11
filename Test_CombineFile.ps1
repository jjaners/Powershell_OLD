# Check if combined file exists
$testpath = Test-Path D:\PSInData\Users-Migration\BaseFile\combined_$date.csv

if ($testpath -eq $true)
{
    Write-Host "  combined_$date.csv exists" -ForegroundColor Green
}
else
{
    Write-Host "  Please create combined_$date.csv before continueing" -ForegroundColor Red
}
 
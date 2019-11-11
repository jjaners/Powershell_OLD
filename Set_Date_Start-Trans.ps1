#=== Date for file to run
$date = get-date -Date $(get-date).AddDays(1) -Format yyyyMMdd

#=== Verbose pref ===
$VerbosePreference="SilentlyContinue"

#=== Import Module ===
Import-Module ActiveDirectory

#=== Start Transcript ======================================================
#$TransDate = get-date -Format yyyyMMddHHmm
Start-Transcript -Path "D:\Logs\Mig_Transcript-1_$Date.txt" -NoClobber
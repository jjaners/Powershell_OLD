# Script to base moving user objects with logging

$Users=Import-csv c:\users.csv 
$failedUsers = @()
$usersAlreadyExist =@()
$successUsers = @()
$VerbosePreference = "Continue"
$LogFolder = "C:\temp"
ForEach($User in $Users)
{
   $FullName = $User.FirstName + " " + $User.LastName
   $SAM = $User.FirstName.Substring(0,1) + $User.LastName
   $dnsroot = '@' + (Get-ADDomain).dnsroot
   $UPN = $SAM + "$dnsroot "
   $OU="CN=users, DC=Domain,DC=COM"
   $email=$Sam + "$dnsroot "

try {
    if (!(get-aduser -Filter {samaccountname -eq "$SAM"})){
        New-ADUser -Name $FullName -AccountPassword (ConvertTo-SecureString “Password!1234” -AsPlainText -force) -GivenName $User.FirstName  -Path $OU -SamAccountName $SAM -Surname $User.LastName  -UserPrincipalName $UPN -EmailAddress $Email -Enabled $TRUE
        Write-Verbose "[PASS] Created $FullName"
        $successUsers += $FullName
    }
    else {
        Write-Warning "[WARNING] Samaccount for username [$($FullName)] already exists"
        $usersAlreadyExist += $FullName
    }
}
catch {
    Write-Warning "[ERROR]Can't create user [$($FullName)] : $_"
    $failedUsers += $FullName
}
}
if ( !(test-path $LogFolder)) {
    Write-Verbose "Folder [$($LogFolder)] does not exist, creating"
    new-item $LogFolder -Force 
}

Write-verbose "Writing logs"
$failedUsers | out-file -FilePath  $LogFolder\FailedUsers.log -Force -Verbose
$usersAlreadyExist | out-file -FilePath  $LogFolder\usersAlreadyExist.log -Force -Verbose
$successUsers | out-file -FilePath  $LogFolder\successUsers.log -Force -Verbose
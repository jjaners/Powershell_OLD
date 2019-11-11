# Create User Print share

#Log File Info
$Date = Get-Date -Format yyyyMMdd
$sLogPath = "D:\Logs\Print-Share"
$sLogName = "createPrintShare" +"$Date" + ".log"
$sLogFileFullName = $sLogPath + "\" + $sLogName
$remoteFolder = "\\NAS004\te1hf001$"
#$users = Get-ADUser -Filter * -SearchBase "OU=Test-Users,OU=Users,OU=CoS,DC=ad,DC=stockholm,DC=se" | select samAccountName
$users = Import-Csv "D:\PSInData\Users-Migration\BaseFile\TestPrintShare.CSV" #Header must be samAccountName

#Check if file exists and delete if it does
If((Test-Path -Path $sLogFileFullName)){
    Remove-Item -Path $sLogFileFullName -Force
}
    
#Create file and start logging
New-Item -Path $sLogFileFullName -Name $LogName -ItemType File
    
Add-Content -Path $sLogFileFullName -Value "***************************************************************************************************"
Add-Content -Path $sLogFileFullName -Value "Started processing at [$([DateTime]::Now)]."
Add-Content -Path $sLogFileFullName -Value "***************************************************************************************************"
Add-Content -Path $sLogFileFullName -Value ""


Function Write-Log {
    [CmdletBinding()]
    [Alias()]
    Param
    (
        #Text to add to log
        [Parameter(Mandatory = $true)]
        $sText
    )

    Add-Content -Path $sLogFileFullName -Value "[$([DateTime]::Now)] `t $sText"
}


foreach($user in $users)
{
    $userID = $user.samAccountName
    $fullPath = "$remoteFolder\$userID"
    
    if(!(Test-Path -Path $fullPath )){
        Write-Host "Creting folder: $fullPath"
           Write-Log "Creting folder: $fullPath"
        $homeShare = New-Item -path $fullPath -ItemType Directory -force -ea Stop

        $acl = Get-Acl $homeShare

        $FileSystemRights = [System.Security.AccessControl.FileSystemRights]"ReadAndExecute","DeleteSubdirectoriesAndFiles"
        $AccessControlType = [System.Security.AccessControl.AccessControlType]::Allow
        $InheritanceFlags = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
        $PropagationFlags = [System.Security.AccessControl.PropagationFlags]"None"

        $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule ($userID, $FileSystemRights, $InheritanceFlags, $PropagationFlags, $AccessControlType)
        $acl.AddAccessRule($AccessRule)
        Set-Acl -Path $homeShare -AclObject $acl -ea Stop
         Write-Log "Folder created: $fullPath"
         Write-Host "Folder created: $fullPath"
    }
    else {
           Write-Host "Folder Exist: $fullPath"
           Write-Log "Folder Exist: $fullPath"
    }
} 

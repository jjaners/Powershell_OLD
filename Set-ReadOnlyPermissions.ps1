$ADUsers = Get-Content D:\Powershell\InData\userlist2.csv #-Delimiter ";"
#$ADUsers = Import-csv D:\Powershell\InData\userlist2.csv -Delimiter ";" -Header ADUsers
$ErrorlogPath = "D:\logs\Missinghomefolder.log"

foreach ($User in $ADUsers)
{

    #$ADU = Get-ADUser -Identity "$user" -Properties SamAccountName, homedirectory | select SamAccountName, homedirectory

    #$Account = $User.SamAccountName
    #$homeShare = $User.HomeDirectory
    $Account = Get-ADUser -Identity "$user" -Properties SamAccountName | select -ExpandProperty SamAccountName
    $homeShare = Get-ADUser -Identity "$user" -Properties homedirectory | select -ExpandProperty homedirectory


    if (test-Path $homeShare) {
        $acl = Get-Acl $homeShare
        #$FileSystemRights = [System.Security.AccessControl.FileSystemRights]"FullControl"
        $FileSystemRights = [System.Security.AccessControl.FileSystemRights]"ReadAndExecute"
        #$FileSystemRights = [System.Security.AccessControl.FileSystemRights]"Modify"
        $AccessControlType = [System.Security.AccessControl.AccessControlType]::Allow
        $InheritanceFlags = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
        $PropagationFlags = [System.Security.AccessControl.PropagationFlags]"None"
        $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule ($Account, $FileSystemRights, $InheritanceFlags, $PropagationFlags, $AccessControlType)
        $acl.AddAccessRule($AccessRule)
        Set-Acl -Path $homeShare -AclObject $acl -ea Stop
    }
    else {
    Set-Content -Path $ErrorlogPath -value "$Account homefolder missing $homedir"
    }
}
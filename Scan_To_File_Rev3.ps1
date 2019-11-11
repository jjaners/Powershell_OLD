$SetHomeDIR = Read-Host -Prompt 'Set Home Directory for new user? (y or n)'
    if ($SetHomeDIR -eq 'y')
        {
            # DEFINE - Set all variables by prompting Admin for correct Home Folder Directory & Drive Paths
            $ServerPATH = Read-Host -Prompt 'Enter Local Path to Parent Home Folder Directory (ex: \\server\share\Home)'
            $HomeDIR = "$ServerPATH\$Global:NewUser"
            # DEFINE - User Account SID >>> Had issues getting this formatted properly, so I converted it to the SID which worked perfectly
            $UserSID = (Get-ADUser $Global:ADUser.sAMAccountName).SID
            # ACTION - Create New Home Folder
            New-Item -ItemType Directory -Path $HomeDIR
            # Uses the 'NTFS Security' Module which must be installed via "Install-Module -Name NTFSSecurity"
            # DEFINE - Get current Access Control Level for New Home Folder
            Get-NTFSAccess -Path $HomeDIR
            # ACTION - Set Permissions, Inheritance/Propagation Flags, and Access Control for new Home Folder
            Write-Host = "Adding NTFS Access to new home folder. Please wait..."
            Add-NTFSAccess -Path $HomeDIR -Account $UserSID -AccessRights FullControl -AccessType Allow -AppliesTo ThisFolderSubfoldersAndFiles -PassThru
            Write-Host '#'
            # ACTION - Update the Home Directory
            Set-ADUser -Server $Global:LocalDC -Credential $Global:AdminCreds -Identity $Global:NewUser -Replace @{HomeDirectory=$HomeDIR}
            # ACTION - Update the Home Drive
            Set-ADUser -Server $Global:LocalDC -Credential $Global:AdminCreds -Identity $Global:NewUser -Replace @{HomeDrive="H"}
        }
    else
        {
            Write-Host 'No Home Directory created for new user. Moving on!...'
        }
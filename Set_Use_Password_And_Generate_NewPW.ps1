function New-SWRandomPassword {
    <#
    .Synopsis
       Generates one or more complex passwords designed to fulfill the requirements for Active Directory
    .DESCRIPTION
       Generates one or more complex passwords designed to fulfill the requirements for Active Directory
    .EXAMPLE
       New-SWRandomPassword
       C&3SX6Kn

       Will generate one password with a length between 8  and 12 chars.
    .EXAMPLE
       New-SWRandomPassword -MinPasswordLength 8 -MaxPasswordLength 12 -Count 4
       7d&5cnaB
       !Bh776T"Fw
       9"C"RxKcY
       %mtM7#9LQ9h

       Will generate four passwords, each with a length of between 8 and 12 chars.
    .EXAMPLE
       New-SWRandomPassword -InputStrings abc, ABC, 123 -PasswordLength 4
       3ABa

       Generates a password with a length of 4 containing atleast one char from each InputString
    .EXAMPLE
       New-SWRandomPassword -InputStrings abc, ABC, 123 -PasswordLength 4 -FirstChar abcdefghijkmnpqrstuvwxyzABCEFGHJKLMNPQRSTUVWXYZ
       3ABa

       Generates a password with a length of 4 containing atleast one char from each InputString that will start with a letter from 
       the string specified with the parameter FirstChar
    .OUTPUTS
       [String]
    .NOTES
       Written by Simon Wåhlin, blog.simonw.se
       I take no responsibility for any issues caused by this script.
    .FUNCTIONALITY
       Generates random passwords
    .LINK
       http://blog.simonw.se/powershell-generating-random-password-for-active-directory/
   
    #>
    [CmdletBinding(DefaultParameterSetName='FixedLength',ConfirmImpact='None')]
    [OutputType([String])]
    Param
    (
        # Specifies minimum password length
        [Parameter(Mandatory=$false,
                   ParameterSetName='RandomLength')]
        [ValidateScript({$_ -gt 0})]
        [Alias('Min')] 
        [int]$MinPasswordLength = 8,
        
        # Specifies maximum password length
        [Parameter(Mandatory=$false,
                   ParameterSetName='RandomLength')]
        [ValidateScript({
                if($_ -ge $MinPasswordLength){$true}
                else{Throw 'Max value cannot be lesser than min value.'}})]
        [Alias('Max')]
        [int]$MaxPasswordLength = 12,

        # Specifies a fixed password length
        [Parameter(Mandatory=$false,
                   ParameterSetName='FixedLength')]
        [ValidateRange(1,2147483647)]
        [int]$PasswordLength = 8,
        
        # Specifies an array of strings containing charactergroups from which the password will be generated.
        # At least one char from each group (string) will be used.
        [String[]]$InputStrings = @('abcdefghijkmnpqrstuvwxyz', 'ABCEFGHJKLMNPQRSTUVWXYZ', '23456789', '!?#%'),

        # Specifies a string containing a character group from which the first character in the password will be generated.
        # Useful for systems which requires first char in password to be alphabetic.
        [String] $FirstChar,
        
        # Specifies number of passwords to generate.
        [ValidateRange(1,2147483647)]
        [int]$Count = 1
    )
    Begin {
        Function Get-Seed{
            # Generate a seed for randomization
            $RandomBytes = New-Object -TypeName 'System.Byte[]' 4
            $Random = New-Object -TypeName 'System.Security.Cryptography.RNGCryptoServiceProvider'
            $Random.GetBytes($RandomBytes)
            [BitConverter]::ToUInt32($RandomBytes, 0)
        }
    }
    Process {
        For($iteration = 1;$iteration -le $Count; $iteration++){
            $Password = @{}
            # Create char arrays containing groups of possible chars
            [char[][]]$CharGroups = $InputStrings

            # Create char array containing all chars
            $AllChars = $CharGroups | ForEach-Object {[Char[]]$_}

            # Set password length
            if($PSCmdlet.ParameterSetName -eq 'RandomLength')
            {
                if($MinPasswordLength -eq $MaxPasswordLength) {
                    # If password length is set, use set length
                    $PasswordLength = $MinPasswordLength
                }
                else {
                    # Otherwise randomize password length
                    $PasswordLength = ((Get-Seed) % ($MaxPasswordLength + 1 - $MinPasswordLength)) + $MinPasswordLength
                }
            }

            # If FirstChar is defined, randomize first char in password from that string.
            if($PSBoundParameters.ContainsKey('FirstChar')){
                $Password.Add(0,$FirstChar[((Get-Seed) % $FirstChar.Length)])
            }
            # Randomize one char from each group
            Foreach($Group in $CharGroups) {
                if($Password.Count -lt $PasswordLength) {
                    $Index = Get-Seed
                    While ($Password.ContainsKey($Index)){
                        $Index = Get-Seed                        
                    }
                    $Password.Add($Index,$Group[((Get-Seed) % $Group.Count)])
                }
            }

            # Fill out with chars from $AllChars
            for($i=$Password.Count;$i -lt $PasswordLength;$i++) {
                $Index = Get-Seed
                While ($Password.ContainsKey($Index)){
                    $Index = Get-Seed                        
                }
                $Password.Add($Index,$AllChars[((Get-Seed) % $AllChars.Count)])
            }
            Write-Output -InputObject $(-join ($Password.GetEnumerator() | Sort-Object -Property Name | Select-Object -ExpandProperty Value))
        }
    }
}

# === Variables ===

$Date = Get-Date -Format yyyyMMdd
$DCTieto = "wsdc003.ad.stockholm.se"

# === MessageBox ===

Add-Type -AssemblyName PresentationFramework
[System.Windows.MessageBox]::Show('Select input CSV containing only samaccountnames.','File Selection info','OK','Info')
#[System.Windows.MessageBox]::Show('Select input CSV containing only samaccountnames.')

# === Browse for file funtionality ===

    param(

        [Parameter(ValueFromPipeline=$true,HelpMessage="Enter CSV path(s)")]
        [String[]]$Path = $null
    )

    $InitialDirectory = "D:\PSInData\Password_Change\IN_Data\"

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

    #Get-Content $path

# === Loop through list and set Password ===

#$UsersetPasswordList = Import-Csv "D:\PSInData\Password_Change\IN_Data\SmartCard_Not_Req_$date.csv" -Header SamAccountname
$UsersetPasswordList = Import-Csv $Path -Header SamAccountname | select -Skip 1
#$UsersetPasswordList

        $Report1 = @()
        foreach($setUserPassword in $UsersetPasswordList){
            
            $user = Get-ADUser $setUserPassword #-Properties Displayname, SamAccountName, givenname, Surname | select -ExpandProperty Displayname
            $GivenName = $user.GivenName
            $SurName = $user.Surname
            $Displayname = $user.GivenName + " " + $user.Surname #-Properties Displayname | select -ExpandProperty Displayname
            $SamAccountName = $setUserPassword.SamAccountName
            $Password = (New-SWRandomPassword -PasswordLength 12)

            set-aduser -Identity $Samaccountname -SmartcardLogonRequired $false -Server $DCTieto #-WhatIf

            Set-ADAccountPassword -Identity $Samaccountname -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $Password -Force) -Server $DCTieto #-WhatIf

            $Report1 += New-Object PSObject -Property @{
            GivenName           = $GivenName
            Surname             = $SurName
            DisplayName         = $Displayname
            SamAccountName      = $SamAccountName
            Password            = $Password
            }

        }

                
        $Report1 | select 'GivenName', 'SurName', 'DisplayName', 'Samaccountname', 'Password' |`
         Export-Csv -Path "D:\PSInData\Password_Change\OUT_Data\PasswordList_$date.csv" -Delimiter ";" -Encoding UTF8 -NoTypeInformation

        #Get-Content '\\wsinfra001\c$\Scripts\Mikael\Set-Password-ON-Users\Lists\PasswordListFB2019-06-11.csv'
        Get-Content "D:\PSInData\Password_Change\OUT_Data\PasswordList_$date.csv"

        # === Test Passwords =========================================

        <#
        .Synopsis
        Verify Active Directory credentials

        .DESCRIPTION
        This function takes a user name and a password as input and will verify if the combination is correct. The function returns a boolean based on the result.

        .NOTES   
        Name: Test-ADCredential
        Author: Jaap Brasser
        Version: 1.0  
        DateUpdated: 2013-05-10

        .PARAMETER UserName
        The samaccountname of the Active Directory user account
            
        .PARAMETER Password
        The password of the Active Directory user account

        .EXAMPLE
        Test-ADCredential -username jaapbrasser -password Secret01

        Description:
        Verifies if the username and password provided are correct, returning either true or false based on the result
        #>


        
        function Test-ADCredential {
            [CmdletBinding()]
            Param
            (
                [string]$UserName,
                [string]$Password
            )
            if (!($UserName) -or !($Password)) {
                Write-Warning 'Test-ADCredential: Please specify both user name and password'
            } else {
                Add-Type -AssemblyName System.DirectoryServices.AccountManagement
                $DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('domain')
                $DS.ValidateCredentials($UserName, $Password)
            }
        }



        $report1 | %{Test-ADCredential -UserName $_.samaccountname -Password $_.Password}
        
        Write-Host "File is located in D:\PSInData\Password_Change\OUT_Data\PasswordList_$date.csv"

        # === Moves input file to DONE folder after prcessing it ===
        Move-Item -Path $Path -Destination "D:\PSInData\Password_Change\IN_Data\Done\"
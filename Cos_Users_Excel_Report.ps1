$users = Get-ADUser -SearchBase 'OU=Users,OU=CoS,DC=ad,DC=stockholm,DC=se' -Properties samaccountname -Filter * | select -ExpandProperty SamAccountname
<#
$Results = @()
foreach ($user in $users)
{
    $manager = Get-ADUser $user -Properties manager | select -ExpandProperty manager

   # check the value in the report, and if in Cos/Users then green
}
#>

# Import module
$VerbosePreference="SilentlyContinue"
Import-Module ImportExcel, ActiveDirectory

#Write-Host "NOTE! Please check Date variable before continueing" -ForegroundColor Cyan
#Read-Host -Prompt "Press Enter to continue..."

#=== Variables ==================
#$date = read-host "Enter date in format yyyyMMdd"
$DCTieto = "wsdc003.ad.stockholm.se"
#$Masterlist = Import-Csv "D:\PSInData\Users-Migration\BaseFile\combined_$date.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate -Delimiter "," | select -Skip 1
#$Masterlist = Import-Csv "D:\PSInData\Users-Migration\Extra\extra-20190610.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate -Delimiter ";" | select -Skip 1
#$users = $Masterlist.samaccountname

# User in data
#$Users = Get-ADUser -Filter * -SearchBase "OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se" -Properties * | select -First 10
#$Users = Import-Csv "D:\PSInData\Users-Migration\BaseFile\combined_$date.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate -Delimiter "," | select -Skip 1
#| select -ExpandProperty samaccountname

$Results = @()

foreach ($U in $Users)
{
  
    $User = Get-ADUser $U -Properties * -Server $DCTieto
        
    # Variables
        $Sam = $U #$User.Samaccountname
        $ADUserExists = If ((Get-ADUser -Filter {SamAccountName -eq $U}) -eq $Null) {Write-Output "NO"} Else {Write-Output "YES"}
        #If ($User -eq $Null) {"NOT in AD"} Else {"IN AD"}
        $distinguishedName = $user.distinguishedName
        $Exchange = $User.homeMDB
        $Skype = $user."msRTCSIP-PrimaryHomeServer"
        $sthlmVerksamhetsId = $user.sthlmVerksamhetsId
        $sthlmForvaltningsNr = $User.sthlmForvaltningsNr
        $sthlmKontoTyp = $User.sthlmKontoTyp
        $userAccountControl = $User.userAccountControl
        $employeeType = $User.employeeType
        $ScanToFile = test-path \\NAS004\te1hf001$\$U
        $Manager = $user.Manager
        
        #$ScanToFile =
        #$HomeFolder = 
        #$GroupToGroup =
        #$CommonFolders =
        
    $Results += New-Object PSObject -Property @{
        SamAccountname      = $U
        ADUserExists        = $ADUserExists
        distinguishedName   = $distinguishedName
        Exchange            = $Exchange
        Skype               = $Skype
        sthlmVerksamhetsId  = $sthlmVerksamhetsId
        sthlmForvaltningsNr = $sthlmForvaltningsNr
        sthlmKontoTyp       = $sthlmKontoTyp
        userAccountControl  = $userAccountControl
        employeeType        = $employeeType
        ScanToFile          = $ScanToFile
        Manager             = $manager
        #UserName         = $user.name
        #Orphan           = ($user.Login -eq "")
        }
    
        # Clear variables
        Clear-variable -Name "User"
        Clear-variable -Name "U"
        Clear-variable -Name "Sam"
        Clear-variable -Name "ADUserExists"
        Clear-variable -Name "distinguishedName"
        Clear-variable -Name "Exchange"
        Clear-variable -Name "Skype"
        Clear-variable -Name "sthlmVerksamhetsId"
        Clear-variable -Name "sthlmForvaltningsNr"
        Clear-variable -Name "sthlmKontoTyp"
        Clear-variable -Name "userAccountControl"
        Clear-variable -Name "employeeType"
        Clear-variable -Name "ScanToFile"
        Clear-variable -Name "Manager"
    
    <#
        $objectProperty.Add('SamAccountname',$Sam)
        $objectProperty.Add('distinguishedName',$distinguishedNam)
        $objectProperty.Add('Exchange',$Exchange)
        $objectProperty.Add('Skype',$Skype)
        $objectProperty.Add('sthlmVerksamhetsId',$sthlmVerksamhetsId)
        $objectProperty.Add('sthlmForvaltningsNr',$sthlmForvaltningsNr)
        $ObjectProperty.Add('sthlmKontoTyp',$sthlmKontoTyp)
        $objectProperty.Add('userAccountControl',$userAccountControl)
        $objectProperty.Add('employeeType',$employeeType)
    #>

    #$Results += New-Object -TypeName psobject -Property $objectProperty
    #$Results =+ $Object
    #$U = Get-ADUser -SearchBase "OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se" -Identity $user.samaccountname | select -ExpandProperty samaccountname
    #-SearchBase "OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se" -Identity $user.samaccountname #| select -ExpandProperty samaccountname
    
    #$Result += $U

    #Write-Host $U
    
}

# ImportExcel variables
#$SamColor = New-ConditionalText -Range "A:A" Blue Cyan


# Results to Excel Formated
$Results | select 'Samaccountname', 'ADUserExists', 'distinguishedName', 'Exchange', 'Skype', 'sthlmVerksamhetsId', 'sthlmForvaltningsNr', 'sthlmKontoTyp', 'userAccountControl', 'employeeType', 'ScanToFile', 'Manager' |`
 Export-csv D:\Logs\Report\Cos_Users_Excel_Report_$date.csv -NoTypeInformation #-ConditionalText $SamColor


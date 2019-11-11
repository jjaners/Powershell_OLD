# Get data for Repport file

#=== Date for file to run
#$date = get-date -Date $(get-date).AddDays(1) -Format yyyyMMdd
#$date = read-host "Enter date in format yyyyMMdd"

# Test if there is a combined file 
$testpath = Test-Path D:\PSInData\Users-Migration\BaseFile\combined_$date.csv

if ($testpath -eq $False)
{
    Write-Host "  .:| No combined file exists |:.   " -ForegroundColor Red
}
else
{

# Import module
$VerbosePreference="SilentlyContinue"
Import-Module ActiveDirectory
# ImportExcel, 

#Write-Host "NOTE! Please check Date variable before continueing" -ForegroundColor Cyan
#Read-Host -Prompt "Press Enter to continue..."

#=== Variables ==================
#$date = read-host "Enter date in format yyyyMMdd"
#$DefaultDate = get-date -Format yyyyMMdd
#$defaultValue = $DefaultDate
#$Date = if ($value = Read-Host -Prompt "Please enter a date OR Enter to set ($defaultValue)") { $value } else { $defaultValue }
$DCTieto = "wsdc003.ad.stockholm.se"
$Masterlist = Import-Csv "D:\PSInData\Users-Migration\BaseFile\combined_$date.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate -Delimiter "," | select -Skip 1
#$Masterlist = Import-Csv "D:\PSInData\Users-Migration\Extra\extra-20190610.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate -Delimiter ";" | select -Skip 1
$users = $Masterlist.samaccountname

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
        $Manager = $User.Manager
        $FNrTranslate = if ($sthlmForvaltningsNr -like '108') {"Valnämnden"}
                        Elseif ($sthlmForvaltningsNr -like '110') {"Stadsledningskontoret"}
                        Elseif ($sthlmForvaltningsNr -like '113') {"Socialförvaltningen"}
                        Elseif ($sthlmForvaltningsNr -like '115') {"Kulturförvaltningen"}
                        Elseif ($sthlmForvaltningsNr -like '116') {"Stadsbyggnadskontoret"}
                        Elseif ($sthlmForvaltningsNr -like '117') {"Utbildningsförvaltningen"}
                        Elseif ($sthlmForvaltningsNr -like '120') {"Stockholms stadsarkiv"}
                        Elseif ($sthlmForvaltningsNr -like '122') {"Äldreförvaltningen"}
                        Elseif ($sthlmForvaltningsNr -like '126') {"Överförmyndarförvaltningen"}
                        Elseif ($sthlmForvaltningsNr -like '131') {"Revisionskontoret"}
                        Elseif ($sthlmForvaltningsNr -like '132') {"Idrottsförvaltningen"}
                        Elseif ($sthlmForvaltningsNr -like '168') {"Kyrkogårdsförvaltningen"}
                        Elseif ($sthlmForvaltningsNr -like '169') {"Miljöförvaltningen"}
                        Elseif ($sthlmForvaltningsNr -like '177') {"Fastighetskontoret"}
                        Elseif ($sthlmForvaltningsNr -like '181') {"Trafikkontoret"}
                        Elseif ($sthlmForvaltningsNr -like '183') {"Exploateringskontoret"}
                        Elseif ($sthlmForvaltningsNr -like '190') {"Serviceförvaltningen"}
                        Elseif ($sthlmForvaltningsNr -like '191') {"Arbetsmarknadsförvaltningen"}
                        Elseif ($sthlmForvaltningsNr -like '200') {"Stockholms Stadshus Ab"}
                        Elseif ($sthlmForvaltningsNr -like '212') {"Stokab Ab"}
                        Elseif ($sthlmForvaltningsNr -like '213') {"AB Familjebostäder"}
                        Elseif ($sthlmForvaltningsNr -like '216') {"AB Stockholmshem"}
                        Elseif ($sthlmForvaltningsNr -like '217') {"AB Svenska Bostäder"}
                        Elseif ($sthlmForvaltningsNr -like '225') {"Invest Stockholm Business Region Ab"}
                        Elseif ($sthlmForvaltningsNr -like '228') {"Stockholms Stads Parkerings AB"}
                        Elseif ($sthlmForvaltningsNr -like '235') {"Skolfastigheter i Stockholm Ab, SISAB"}
                        Elseif ($sthlmForvaltningsNr -like '228') {"Stockholms Stads Parkerings AB"}
                        Elseif ($sthlmForvaltningsNr -like '235') {"Skolfastigheter i Stockholm Ab, SISAB"}
                        Elseif ($sthlmForvaltningsNr -like '249') {"Stockholm Globe Arena Fastigheter Ab"}
                        Elseif ($sthlmForvaltningsNr -like '251') {"Stockholms Stadsteater Ab"}
                        Elseif ($sthlmForvaltningsNr -like '278') {"Stockholms Hamn Ab"}
                        Elseif ($sthlmForvaltningsNr -like '291') {"Bostadsförmedlingen i Stockholm Ab"}
                        Elseif ($sthlmForvaltningsNr -like '292') {"S:t Erik Markutveckling Ab"}
                        Elseif ($sthlmForvaltningsNr -like '296') {"Stockholm Vatten AB"}
                        Elseif ($sthlmForvaltningsNr -like '298') {"S:t Erik Försäkrings Ab"}
                        Elseif ($sthlmForvaltningsNr -like '361') {"Stockholm Business Region AB"}
                        Elseif ($sthlmForvaltningsNr -like '362') {"Micasa Fastigheter i Stockholm Ab"}
                        Elseif ($sthlmForvaltningsNr -like '367') {"Visit Stockholm Ab"}
                        Elseif ($sthlmForvaltningsNr -like '385') {"S:t Erik Livförsäkring Ab"}
                        Elseif ($sthlmForvaltningsNr -like '391') {"S:t Erik Kommunikation Ab"}
                        Elseif ($sthlmForvaltningsNr -like '470') {"Stockholm Avfall AB"}
                        Elseif ($sthlmForvaltningsNr -like '701') {"Rinkeby-Kista sdf"}
                        Elseif ($sthlmForvaltningsNr -like '703') {"Spånga-Tensta sdf"}
                        Elseif ($sthlmForvaltningsNr -like '704') {"Hässelby-Vällingby sdf"}
                        Elseif ($sthlmForvaltningsNr -like '706') {"Bromma sdf"}
                        Elseif ($sthlmForvaltningsNr -like '708') {"Kungsholmens sdf"}
                        Elseif ($sthlmForvaltningsNr -like '709') {"Norrmalms sdf"}
                        Elseif ($sthlmForvaltningsNr -like '710') {"Östermalms sdf"}
                        Elseif ($sthlmForvaltningsNr -like '712') {"Södermalms sdf"}
                        Elseif ($sthlmForvaltningsNr -like '714') {"Enskede-Årsta-Vantörs sdf"}
                        Elseif ($sthlmForvaltningsNr -like '715') {"Skarpnäcks sdf"}
                        Elseif ($sthlmForvaltningsNr -like '718') {"Farsta stadsdelsförvaltning"}
                        Elseif ($sthlmForvaltningsNr -like '721') {"Älvsjö sdf"}
                        Elseif ($sthlmForvaltningsNr -like '722') {"Hägersten-Liljeholmens sdf"}
                        Elseif ($sthlmForvaltningsNr -like '724') {"Skärholmens sdf"}
                        Elseif ($sthlmForvaltningsNr -like '999') {"Testbolag AB"}
                        
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
        Manager             = $Manager
        Versamhet           = $FNrTranslate
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
        Clear-Variable -name "FNrTranslate"
    
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
$Results | select 'Samaccountname', 'ADUserExists', 'distinguishedName', 'Exchange', 'Skype', 'sthlmVerksamhetsId', 'sthlmForvaltningsNr', 'sthlmKontoTyp', 'userAccountControl', 'employeeType', 'ScanToFile', 'Manager', 'Versamhet' |`
 Export-csv D:\Logs\Report\User_Mig_Excel_Report_$date.csv -NoTypeInformation -Encoding UTF8 #-ConditionalText $SamColor
}


# === All sthlmForvaltningsNr ===

# === Import module ===
Import-Module ActiveDirectory
 
#-Properties Name,Samaccountname,Sthlmverksamhetsnr,Company,Manageby,Useraccountcountroll,Whencreated,Employeetype,Mail,Sthlmfakturaref | select Name,Samaccountname,Sthlmverksamhetsnr,Company,Manageby,Useraccountcountroll,Whencreated,Employeetype,Mail,Sthlmfakturaref

# === Variables ===
$Date = get-date -Format yyyyMMdd-HHmm
$DCTieto = "wsdc003.ad.stockholm.se"
$Masterlist = @(Get-ADUser -SearchBase "OU=Users,OU=CoS,DC=ad,DC=stockholm,DC=se" -SearchScope OneLevel -Filter *)
$users = $Masterlist.samaccountname

$Results = @()
foreach ($U in $Users)
{
   
    $User = Get-ADUser $U -Properties * -Server $DCTieto
    #Samaccountname,sthlmForvaltningsNr,Company,Manager,userAccountControl,Whencreated,Employeetype,Mail,Sthlmfakturaref | select -ExpandProperty Samaccountname,sthlmForvaltningsNr,Company,Manager,userAccountControl,Whencreated,Employeetype,Mail,Sthlmfakturaref #-Server $DCTieto
    
    #Get-ADUser ac19243 -Properties Samaccountname,sthlmForvaltningsNr,Company,Manager,userAccountControl,Whencreated,Employeetype,Mail,Sthlmfakturaref | select Samaccountname,sthlmForvaltningsNr,Company,Manager,userAccountControl,Whencreated,Employeetype,Mail,Sthlmfakturaref

    # Variables
    $Samaccountname = $U
    $Name = $User.displayname
    $sthlmForvaltningsNr = $User.sthlmForvaltningsNr
    $Company = $User.Company
    $Manager = Get-ADUser $User.Manager -Properties displayname | select displayname #/ Lösa upp till Displayname
    $userAccountControl = $User.userAccountControl
    $Whencreated = $User.Whencreated
    $Employeetype = $User.Employeetype
    $Mail = $User.Mail
    $Sthlmfakturaref = $User.Sthlmfakturaref
    $FNrTranslate = if ($sthlmForvaltningsNr -like '108') {"Valnämnden"}
                    Elseif ($sthlmForvaltningsNr -like '110') {"Stadsledningskontoret"}
                    Elseif ($sthlmForvaltningsNr -like '111') {"KF/KS kansli"}
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
                    Elseif ($sthlmForvaltningsNr -like '187') {"Trafikkontoret-Avfallsavdelningen"}
                    Elseif ($sthlmForvaltningsNr -like '190') {"Serviceförvaltningen"}
                    Elseif ($sthlmForvaltningsNr -like '191') {"Arbetsmarknadsförvaltningen"}
                    Elseif ($sthlmForvaltningsNr -like '200') {"Stockholms Stadshus Ab"}
                    Elseif ($sthlmForvaltningsNr -like '212') {"Stokab Ab"}
                    Elseif ($sthlmForvaltningsNr -like '213') {"AB Familjebostäder"}
                    Elseif ($sthlmForvaltningsNr -like '216') {"AB Stockholmshem"}
                    Elseif ($sthlmForvaltningsNr -like '217') {"AB Svenska Bostäder"}
                    Elseif ($sthlmForvaltningsNr -like '218') {"AB Stadsholmen"}
                    Elseif ($sthlmForvaltningsNr -like '225') {"Invest Stockholm Business Region Ab"}
                    Elseif ($sthlmForvaltningsNr -like '228') {"Stockholms Stads Parkerings AB"}
                    Elseif ($sthlmForvaltningsNr -like '235') {"Skolfastigheter i Stockholm Ab, SISAB"}
                    Elseif ($sthlmForvaltningsNr -like '228') {"Stockholms Stads Parkerings AB"}
                    Elseif ($sthlmForvaltningsNr -like '235') {"Skolfastigheter i Stockholm Ab, SISAB"}
                    Elseif ($sthlmForvaltningsNr -like '249') {"Stockholm Globe Arena Fastigheter Ab"}
                    Elseif ($sthlmForvaltningsNr -like '251') {"Stockholms Stadsteater Ab"}
                    Elseif ($sthlmForvaltningsNr -like '277') {"Kapellskärs Hamn AB"}
                    Elseif ($sthlmForvaltningsNr -like '278') {"Stockholms Hamn Ab"}
                    Elseif ($sthlmForvaltningsNr -like '279') {"Nynäshamns Hamn AB"}
                    Elseif ($sthlmForvaltningsNr -like '291') {"Bostadsförmedlingen i Stockholm Ab"}
                    Elseif ($sthlmForvaltningsNr -like '292') {"S:t Erik Markutveckling Ab"}
                    Elseif ($sthlmForvaltningsNr -like '296') {"Stockholm Vatten AB"}
                    Elseif ($sthlmForvaltningsNr -like '298') {"S:t Erik Försäkrings Ab"}
                    Elseif ($sthlmForvaltningsNr -like '361') {"Stockholm Business Region AB"}
                    Elseif ($sthlmForvaltningsNr -like '362') {"Micasa Fastigheter i Stockholm Ab"}
                    Elseif ($sthlmForvaltningsNr -like '367') {"Visit Stockholm Ab"}
                    Elseif ($sthlmForvaltningsNr -like '385') {"S:t Erik Livförsäkring Ab"}
                    Elseif ($sthlmForvaltningsNr -like '391') {"S:t Erik Kommunikation Ab"}
                    Elseif ($sthlmForvaltningsNr -like '469') {"Stockholm Vatten och Avfall AB"}
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
                    Elseif ($sthlmForvaltningsNr -like '777') {"Tieto Sweden AB"}
                    Elseif ($sthlmForvaltningsNr -like '888') {"Testverksamhet Stockholm"}
                    Elseif ($sthlmForvaltningsNr -like '998') {"AB Stockholmstest"}
                    Elseif ($sthlmForvaltningsNr -like '999') {"Testbolag AB"}
            
        
        $Results += New-Object PSObject -Property @{
            Samaccountname      = $Samaccountname
            Name                = $Name
            sthlmForvaltningsNr = $sthlmForvaltningsNr
            Company             = $Company
            Manager             = $Manager
            userAccountControl  = $userAccountControl
            Whencreated         = $Whencreated
            Employeetype        = $Employeetype
            Mail                = $Mail
            Sthlmfakturaref     = $Sthlmfakturaref
            FNrTranslate        = $FNrTranslate
            }

            # Clear variables
            Clear-variable -Name "Samaccountname"
            Clear-variable -Name "Name"
            Clear-variable -Name "sthlmForvaltningsNr"
            Clear-variable -Name "Company"
            Clear-variable -Name "Manager"
            Clear-variable -Name "userAccountControl"
            Clear-variable -Name "Whencreated"
            Clear-variable -Name "Employeetype"
            Clear-variable -Name "Mail"
            Clear-variable -Name "Sthlmfakturaref"
            Clear-variable -Name "FNrTranslate"
            
    }
        
    # Results to Excel Formated
    $Results | select 'Samaccountname', 'Name', 'sthlmForvaltningsNr', 'Company', 'Manager', 'userAccountControl', 'Whencreated', 'Employeetype', 'Mail', 'Sthlmfakturaref' | Export-csv D:\Logs\Report\SthlmFakturaRef_Report_$date.csv -NoTypeInformation -Encoding UTF8 -Delimiter ',' #-ConditionalText $SamColor
    # , 'FNrTranslate'
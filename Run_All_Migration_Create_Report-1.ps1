﻿    # === Run all Migration scripts in sequenze ===

    # === Variables ===
    $Date = get-date -Format yyyyMMdd
    #$Date = "$D" + "-1"

$testpath_1 = Test-Path "D:\PSInData\Users-Migration\BaseFile\combined_$date-1.csv"
if ($testpath_1 -eq $True)
{
    


    # ===  Start Transcript ===
    Start-Transcript -Path "D:\Logs\RunAll_Transcript_$Date-1.txt" -NoClobber

    # === Move users from DMZ to CoS OU ============================================================================================================ #

    # === Variables === #
    #$date = read-host "Enter date in format yyyyMMdd"
    $DCTieto = "wsdc003.ad.stockholm.se"
    $Masterlist = Import-Csv "D:\PSInData\Users-Migration\BaseFile\combined_$date-1.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate, SthlmFakturaRef -Delimiter "," | select -Skip 1
    #$Masterlist = Import-Csv "D:\PSInData\Users-Migration\Extra\extra-20190610.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate -Delimiter ";" | select -Skip 1
    $users = $Masterlist.samaccountname

    foreach ($User in $Users)
    {
          #  Write-Host "$user"}

        #$UserSam = Get-ADUser -Identity $user | select samaccountname
        $DN = Get-ADUser $user -Properties distinguishedname | select -ExpandProperty distinguishedname
        #$DN = Get-ADUser af23151 -Properties distinguishedname | select -ExpandProperty distinguishedname
    
        # Move to Users_JJ
        Move-ADObject -Identity "$DN" -TargetPath "OU=Users,OU=CoS,DC=ad,DC=stockholm,DC=se" -Server $DCTieto
        #Move-ADObject -Identity "$DN" -TargetPath "OU=Tieto,OU=Users,OU=Fujitsu,OU=DMZ,DC=ad,DC=stockholm,DC=se" -Server $DCTieto
    }
    # =============================================================================================================================================== #

    Start-Sleep -Seconds 5

    # === Set Attributes ============================================================================================================================ #

    #=== Variables ==================
    #$date = read-host "Enter date in format yyyyMMdd"
    $DCTieto = "wsdc003.ad.stockholm.se"
    $Masterlist = Import-Csv "D:\PSInData\Users-Migration\BaseFile\combined_$date.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate, SthlmFakturaRef -Delimiter "," | select -Skip 1
    #$Masterlist = Import-Csv "D:\PSInData\Users-Migration\Extra\extra-20190610.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate -Delimiter ";" | select -Skip 1

    $users = $Masterlist #.samaccountname


    foreach ($User in $Users)
    {
        $U = $user.SamAccountName
        $X = $User.NoSmartcardreq
        $SthlmFakturaRef = $User.SthlmFakturaRef
        # Write-Host $U, $X }
        
        # Per user variables
        $employeeType = Get-ADUser $U -Properties employeeType -Server $DCTieto | select -ExpandProperty employeeType
        $NoSmartcardreq = Get-ADUser $U -Properties employeeType -Server $DCTieto | select -ExpandProperty employeeType
    
        # Need to set this first. Michael want this to be on the account before object are moved to Users.
        set-aduser -Identity $U -Replace @{Pager="NEED_TIETO_ONBOARDING"} -Server $DCTieto

        # Remove Homedrirectory and Homedrive
        set-aduser -Identity $U -Clear HomeDirectory -Server $DCTieto
        Set-ADUser -Identity $U -Clear HomeDrive -Server $DCTieto
        Set-ADUser -Identity $U -Clear ProfilePath -Server $DCTieto
    
        #Make sthlmVerksamhetsId same as sthlmForvaltningsNr  
        $GetUser = Get-ADUser $U -Properties sthlmVerksamhetsId, sthlmForvaltningsNr
        $GetUser | %{Set-ADUser $U -Replace @{sthlmVerksamhetsId = $GetUser.sthlmForvaltningsNr} -Server $DCTieto}

        #Empty this value sthlmKontoTyp
        Set-ADUser $U -Replace @{sthlmKontoTyp = "0"} -Server $DCTieto

        if ($employeeType -like "F")
            {
             Set-ADUser $U -Replace @{extensionAttribute13 = "REPORT_TO_SOA"} -Server $DCTieto
            }
        if ($employeeType -like "a")
            {
             Set-ADUser $U -Replace @{extensionAttribute13 = "REPORT_TO_SOA"} -Server $DCTieto
            }
        if ($employeeType -like "v")
            {
             Set-ADUser $U -Replace @{extensionAttribute13 = "REPORT_TO_SOA"} -Server $DCTieto
            }
        if ($employeeType -like "l")
            {
             Set-ADUser $U -Replace @{employeeType = "k"} -Server $DCTieto
            }
        if ($employeeType -like "k")
            {
             Set-ADUser $U -Replace @{extensionAttribute13 = "REPORT_TO_SOA"} -Server $DCTieto
            }
        If ($User.NoSmartcardreq -notlike "x")
            {
             Set-ADUser $U -Replace @{userAccountControl = "262656"} -Server $DCTieto
            }
        If ($SthlmFakturaRef -NotMatch "^\d+$")
            {
             Set-ADUser $U -Clear SthlmFakturaRef -Server $DCTieto
            }
        else
            {
             Set-ADUser $U -Replace @{SthlmFakturaRef = "$SthlmFakturaRef"} -Server $DCTieto 
            }

    }

    # =============================================================================================================================================== #

    Start-Sleep -Seconds 5

    # === Add user to Appgroups that apply to all users ============================================================================================= #

    #=== Variables ==================
    #$date = read-host "Enter date in format yyyyMMdd"
    $DCTieto = "wsdc003.ad.stockholm.se"
    $Masterlist = Import-Csv "D:\PSInData\Users-Migration\BaseFile\combined_$date-1.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate, SthlmFakturaRef -Delimiter "," | select -Skip 1
    #$Masterlist = Import-Csv "D:\PSInData\Users-Migration\Extra\extra-20190610.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate -Delimiter ";" | select -Skip 1
    $users = $Masterlist.samaccountname

    foreach ($User in $Users)
    {
        #Write-Host "$user"}

        Add-ADGroupMember -Identity "sec-CoS-VDB-App-FJARR" -Members $User -Server $DCTieto
        Add-ADGroupMember -Identity "Tieto Readers" -Members $User -Server $DCTieto
        Add-ADGroupMember -Identity "Cos Readers" -Members $User -Server $DCTieto
        Add-ADGroupMember -Identity "Role-T1-HCPaw-production" -Members $User -Server $DCTieto
        Add-ADGroupMember -Identity "MobileIron-All-Users" -Members $User -Server $DCTieto
        Add-ADGroupMember -Identity "sec-T0-Deny-All-HomeFolders-HCL" -Members $User -Server $DCTieto
    
    }
    # =============================================================================================================================================== #

    Start-Sleep -Seconds 5

    # === Send GO mail to Homefolder crew ===
    $recipients = "LKA <LKA@Tieto.com>, Aaltonen Jyri <Jyri.Aaltonen@tieto.com>, Andersson Mikael (Ext) <ext.mikael.andersson@tieto.com>, Bengtsson Anders <Anders.Bengtsson@tieto.com>, Bilan Vojtech <Vojtech.Bilan@tieto.com>, Bolacky Jiri <Jiri.Bolacky@tieto.com>, Burlin Patrik <Patrik.Burlin@tieto.com>, Drexler Dominik <dominik.drexler@tieto.com>, Hogberg Marika <marika.hogberg@tieto.com>, Janers Jack (Ext) <ext.jack.janers@tieto.com>, Jurcik Jan <Jan.Jurcik@tieto.com>, Karlsson Jan <Jan.Karlsson@tieto.com>, Landberg Patrik <Patrik.Landberg@tieto.com>, Mikunda Marek <Marek.Mikunda@tieto.com>, Stoces Jan <Jan.Stoces@tieto.com>, Waesterberg Jenny <Jenny.Waesterberg@tieto.com>, Wall Michael <Michael.Wall@tieto.com>, Widahl Markus <markus.widahl@tieto.com>, Zwyrtek Martin <martin.zwyrtek@tieto.com>".Split(',')
    Send-MailMessage -From 'AD-Team <AD.NoReply@Tieto.com>' -To $recipients -Cc 'Bengt Jonsson <ext.bengt.jonsson@tieto.com>' -Subject "Usermigration $date-1 Homefolders" -Body "Homefolders are good to go. `n `nRegards `nJack"  -SmtpServer 'extrelay.stockholm.se' -Port '25'

    # === Add to appGroups ========================================================================================================================== #
    $testpath = Test-Path "D:\PSInData\Appdist\User_Appdist_$date.csv"
    if ($testpath -eq $True)
    {
    #=== Variables ==================
    #$date = read-host "Enter date in format yyyyMMdd"
    $DCTieto = "wsdc003.ad.stockholm.se"
    $data = Import-Csv -Header Samaccountname, AppGroup -Delimiter ";" -LiteralPath D:\PSInData\Appdist\User_Appdist_$date.csv

    $AppUsers = $data.Samaccountname | select -Skip 1
    $AppGroupS = $data.AppGroup | select -Skip 1

    #$members = @($AppUsers)

    foreach($user in $appusers)
    {#Write-Host "$user"}
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    if($AppUsers -contains $user){
        
        if ($User -like $AppUsers[0]) { foreach ($group in $AppGroups[0].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[1]) { foreach ($group in $AppGroups[1].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[2]) { foreach ($group in $AppGroups[2].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[3]) { foreach ($group in $AppGroups[3].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[4]) { foreach ($group in $AppGroups[4].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[5]) { foreach ($group in $AppGroups[5].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[6]) { foreach ($group in $AppGroups[6].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[7]) { foreach ($group in $AppGroups[7].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[8]) { foreach ($group in $AppGroups[8].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[9]) { foreach ($group in $AppGroups[9].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[10]) { foreach ($group in $AppGroups[10].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[11]) { foreach ($group in $AppGroups[11].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[12]) { foreach ($group in $AppGroups[12].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[13]) { foreach ($group in $AppGroups[13].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[14]) { foreach ($group in $AppGroups[14].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[15]) { foreach ($group in $AppGroups[15].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[16]) { foreach ($group in $AppGroups[16].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[17]) { foreach ($group in $AppGroups[17].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[18]) { foreach ($group in $AppGroups[18].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[19]) { foreach ($group in $AppGroups[19].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[20]) { foreach ($group in $AppGroups[20].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[21]) { foreach ($group in $AppGroups[21].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[22]) { foreach ($group in $AppGroups[22].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[23]) { foreach ($group in $AppGroups[23].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[24]) { foreach ($group in $AppGroups[24].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[25]) { foreach ($group in $AppGroups[25].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[26]) { foreach ($group in $AppGroups[26].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[27]) { foreach ($group in $AppGroups[27].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[28]) { foreach ($group in $AppGroups[28].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[29]) { foreach ($group in $AppGroups[29].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[30]) { foreach ($group in $AppGroups[30].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[31]) { foreach ($group in $AppGroups[31].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[32]) { foreach ($group in $AppGroups[32].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[33]) { foreach ($group in $AppGroups[33].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[34]) { foreach ($group in $AppGroups[34].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[35]) { foreach ($group in $AppGroups[35].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[36]) { foreach ($group in $AppGroups[36].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[37]) { foreach ($group in $AppGroups[37].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[38]) { foreach ($group in $AppGroups[38].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[39]) { foreach ($group in $AppGroups[39].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[40]) { foreach ($group in $AppGroups[40].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[41]) { foreach ($group in $AppGroups[41].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[42]) { foreach ($group in $AppGroups[42].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[43]) { foreach ($group in $AppGroups[43].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[44]) { foreach ($group in $AppGroups[44].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[45]) { foreach ($group in $AppGroups[45].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[46]) { foreach ($group in $AppGroups[46].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[47]) { foreach ($group in $AppGroups[47].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[48]) { foreach ($group in $AppGroups[48].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[49]) { foreach ($group in $AppGroups[49].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[50]) { foreach ($group in $AppGroups[50].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[51]) { foreach ($group in $AppGroups[51].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[52]) { foreach ($group in $AppGroups[52].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[53]) { foreach ($group in $AppGroups[53].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[54]) { foreach ($group in $AppGroups[54].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[55]) { foreach ($group in $AppGroups[55].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[56]) { foreach ($group in $AppGroups[56].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[57]) { foreach ($group in $AppGroups[57].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[58]) { foreach ($group in $AppGroups[58].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[59]) { foreach ($group in $AppGroups[59].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[60]) { foreach ($group in $AppGroups[60].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[61]) { foreach ($group in $AppGroups[61].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[62]) { foreach ($group in $AppGroups[62].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[63]) { foreach ($group in $AppGroups[63].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[64]) { foreach ($group in $AppGroups[64].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[65]) { foreach ($group in $AppGroups[65].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[66]) { foreach ($group in $AppGroups[66].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[67]) { foreach ($group in $AppGroups[67].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[68]) { foreach ($group in $AppGroups[68].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[69]) { foreach ($group in $AppGroups[69].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[70]) { foreach ($group in $AppGroups[70].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[71]) { foreach ($group in $AppGroups[71].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[72]) { foreach ($group in $AppGroups[72].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[73]) { foreach ($group in $AppGroups[73].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[74]) { foreach ($group in $AppGroups[74].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[75]) { foreach ($group in $AppGroups[75].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[76]) { foreach ($group in $AppGroups[76].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[77]) { foreach ($group in $AppGroups[77].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[78]) { foreach ($group in $AppGroups[78].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[79]) { foreach ($group in $AppGroups[79].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[80]) { foreach ($group in $AppGroups[80].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[81]) { foreach ($group in $AppGroups[81].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[82]) { foreach ($group in $AppGroups[82].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[83]) { foreach ($group in $AppGroups[83].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[84]) { foreach ($group in $AppGroups[84].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[85]) { foreach ($group in $AppGroups[85].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[86]) { foreach ($group in $AppGroups[86].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[87]) { foreach ($group in $AppGroups[87].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[88]) { foreach ($group in $AppGroups[88].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[89]) { foreach ($group in $AppGroups[89].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[90]) { foreach ($group in $AppGroups[90].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[91]) { foreach ($group in $AppGroups[91].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[92]) { foreach ($group in $AppGroups[92].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[93]) { foreach ($group in $AppGroups[93].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[94]) { foreach ($group in $AppGroups[94].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[95]) { foreach ($group in $AppGroups[95].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[96]) { foreach ($group in $AppGroups[96].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[97]) { foreach ($group in $AppGroups[97].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[98]) { foreach ($group in $AppGroups[98].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[99]) { foreach ($group in $AppGroups[99].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[100]) { foreach ($group in $AppGroups[100].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[101]) { foreach ($group in $AppGroups[101].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[102]) { foreach ($group in $AppGroups[102].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[103]) { foreach ($group in $AppGroups[103].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[104]) { foreach ($group in $AppGroups[104].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[105]) { foreach ($group in $AppGroups[105].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[106]) { foreach ($group in $AppGroups[106].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[107]) { foreach ($group in $AppGroups[107].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[108]) { foreach ($group in $AppGroups[108].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[109]) { foreach ($group in $AppGroups[109].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[110]) { foreach ($group in $AppGroups[110].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[111]) { foreach ($group in $AppGroups[111].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[112]) { foreach ($group in $AppGroups[112].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[113]) { foreach ($group in $AppGroups[113].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[114]) { foreach ($group in $AppGroups[114].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[115]) { foreach ($group in $AppGroups[115].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[116]) { foreach ($group in $AppGroups[116].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[117]) { foreach ($group in $AppGroups[117].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[118]) { foreach ($group in $AppGroups[118].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[119]) { foreach ($group in $AppGroups[119].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[120]) { foreach ($group in $AppGroups[120].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[121]) { foreach ($group in $AppGroups[121].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[122]) { foreach ($group in $AppGroups[122].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[123]) { foreach ($group in $AppGroups[123].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[124]) { foreach ($group in $AppGroups[124].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[125]) { foreach ($group in $AppGroups[125].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[126]) { foreach ($group in $AppGroups[126].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[127]) { foreach ($group in $AppGroups[127].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[128]) { foreach ($group in $AppGroups[128].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[129]) { foreach ($group in $AppGroups[129].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[130]) { foreach ($group in $AppGroups[130].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[131]) { foreach ($group in $AppGroups[131].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[132]) { foreach ($group in $AppGroups[132].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[133]) { foreach ($group in $AppGroups[133].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[134]) { foreach ($group in $AppGroups[134].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[135]) { foreach ($group in $AppGroups[135].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[136]) { foreach ($group in $AppGroups[136].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[137]) { foreach ($group in $AppGroups[137].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[138]) { foreach ($group in $AppGroups[138].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[139]) { foreach ($group in $AppGroups[139].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[140]) { foreach ($group in $AppGroups[140].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[141]) { foreach ($group in $AppGroups[141].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[142]) { foreach ($group in $AppGroups[142].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[143]) { foreach ($group in $AppGroups[143].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[144]) { foreach ($group in $AppGroups[144].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[145]) { foreach ($group in $AppGroups[145].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[146]) { foreach ($group in $AppGroups[146].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[147]) { foreach ($group in $AppGroups[147].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[148]) { foreach ($group in $AppGroups[148].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[149]) { foreach ($group in $AppGroups[149].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[150]) { foreach ($group in $AppGroups[150].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[151]) { foreach ($group in $AppGroups[151].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[152]) { foreach ($group in $AppGroups[152].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[153]) { foreach ($group in $AppGroups[153].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[154]) { foreach ($group in $AppGroups[154].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[155]) { foreach ($group in $AppGroups[155].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[156]) { foreach ($group in $AppGroups[156].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[157]) { foreach ($group in $AppGroups[157].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[158]) { foreach ($group in $AppGroups[158].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[159]) { foreach ($group in $AppGroups[159].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[160]) { foreach ($group in $AppGroups[160].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[161]) { foreach ($group in $AppGroups[161].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[162]) { foreach ($group in $AppGroups[162].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[163]) { foreach ($group in $AppGroups[163].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[164]) { foreach ($group in $AppGroups[164].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[165]) { foreach ($group in $AppGroups[165].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[166]) { foreach ($group in $AppGroups[166].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[167]) { foreach ($group in $AppGroups[167].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[168]) { foreach ($group in $AppGroups[168].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[169]) { foreach ($group in $AppGroups[169].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[170]) { foreach ($group in $AppGroups[170].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[171]) { foreach ($group in $AppGroups[171].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[172]) { foreach ($group in $AppGroups[172].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[173]) { foreach ($group in $AppGroups[173].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[174]) { foreach ($group in $AppGroups[174].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[175]) { foreach ($group in $AppGroups[175].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[176]) { foreach ($group in $AppGroups[176].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[177]) { foreach ($group in $AppGroups[177].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[178]) { foreach ($group in $AppGroups[178].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[179]) { foreach ($group in $AppGroups[179].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[180]) { foreach ($group in $AppGroups[180].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[181]) { foreach ($group in $AppGroups[181].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[182]) { foreach ($group in $AppGroups[182].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[183]) { foreach ($group in $AppGroups[183].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[184]) { foreach ($group in $AppGroups[184].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[185]) { foreach ($group in $AppGroups[185].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[186]) { foreach ($group in $AppGroups[186].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[187]) { foreach ($group in $AppGroups[187].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[188]) { foreach ($group in $AppGroups[188].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[189]) { foreach ($group in $AppGroups[189].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[190]) { foreach ($group in $AppGroups[190].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[191]) { foreach ($group in $AppGroups[191].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[192]) { foreach ($group in $AppGroups[192].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[193]) { foreach ($group in $AppGroups[193].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[194]) { foreach ($group in $AppGroups[194].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[195]) { foreach ($group in $AppGroups[195].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[196]) { foreach ($group in $AppGroups[196].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[197]) { foreach ($group in $AppGroups[197].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[198]) { foreach ($group in $AppGroups[198].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[199]) { foreach ($group in $AppGroups[199].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[200]) { foreach ($group in $AppGroups[200].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[201]) { foreach ($group in $AppGroups[201].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[202]) { foreach ($group in $AppGroups[202].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[203]) { foreach ($group in $AppGroups[203].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[204]) { foreach ($group in $AppGroups[204].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[205]) { foreach ($group in $AppGroups[205].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[206]) { foreach ($group in $AppGroups[206].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[207]) { foreach ($group in $AppGroups[207].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[208]) { foreach ($group in $AppGroups[208].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[209]) { foreach ($group in $AppGroups[209].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[210]) { foreach ($group in $AppGroups[210].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[211]) { foreach ($group in $AppGroups[211].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[212]) { foreach ($group in $AppGroups[212].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[213]) { foreach ($group in $AppGroups[213].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[214]) { foreach ($group in $AppGroups[214].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[215]) { foreach ($group in $AppGroups[215].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[216]) { foreach ($group in $AppGroups[216].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[217]) { foreach ($group in $AppGroups[217].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[218]) { foreach ($group in $AppGroups[218].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[219]) { foreach ($group in $AppGroups[219].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[220]) { foreach ($group in $AppGroups[220].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[221]) { foreach ($group in $AppGroups[221].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[222]) { foreach ($group in $AppGroups[222].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[223]) { foreach ($group in $AppGroups[223].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[224]) { foreach ($group in $AppGroups[224].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[225]) { foreach ($group in $AppGroups[225].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[226]) { foreach ($group in $AppGroups[226].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[227]) { foreach ($group in $AppGroups[227].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[228]) { foreach ($group in $AppGroups[228].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[229]) { foreach ($group in $AppGroups[229].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[230]) { foreach ($group in $AppGroups[230].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[231]) { foreach ($group in $AppGroups[231].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[232]) { foreach ($group in $AppGroups[232].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[233]) { foreach ($group in $AppGroups[233].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[234]) { foreach ($group in $AppGroups[234].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[235]) { foreach ($group in $AppGroups[235].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[236]) { foreach ($group in $AppGroups[236].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[237]) { foreach ($group in $AppGroups[237].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[238]) { foreach ($group in $AppGroups[238].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[239]) { foreach ($group in $AppGroups[239].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[240]) { foreach ($group in $AppGroups[240].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[241]) { foreach ($group in $AppGroups[241].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[242]) { foreach ($group in $AppGroups[242].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[243]) { foreach ($group in $AppGroups[243].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[244]) { foreach ($group in $AppGroups[244].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[245]) { foreach ($group in $AppGroups[245].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[246]) { foreach ($group in $AppGroups[246].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[247]) { foreach ($group in $AppGroups[247].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[248]) { foreach ($group in $AppGroups[248].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[249]) { foreach ($group in $AppGroups[249].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[250]) { foreach ($group in $AppGroups[250].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[251]) { foreach ($group in $AppGroups[251].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[252]) { foreach ($group in $AppGroups[252].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[253]) { foreach ($group in $AppGroups[253].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[254]) { foreach ($group in $AppGroups[254].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[255]) { foreach ($group in $AppGroups[255].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[256]) { foreach ($group in $AppGroups[256].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[257]) { foreach ($group in $AppGroups[257].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[258]) { foreach ($group in $AppGroups[258].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[259]) { foreach ($group in $AppGroups[259].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[260]) { foreach ($group in $AppGroups[260].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[261]) { foreach ($group in $AppGroups[261].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[262]) { foreach ($group in $AppGroups[262].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[263]) { foreach ($group in $AppGroups[263].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[264]) { foreach ($group in $AppGroups[264].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[265]) { foreach ($group in $AppGroups[265].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[266]) { foreach ($group in $AppGroups[266].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[267]) { foreach ($group in $AppGroups[267].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[268]) { foreach ($group in $AppGroups[268].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[269]) { foreach ($group in $AppGroups[269].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[270]) { foreach ($group in $AppGroups[270].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[271]) { foreach ($group in $AppGroups[271].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[272]) { foreach ($group in $AppGroups[272].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[273]) { foreach ($group in $AppGroups[273].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[274]) { foreach ($group in $AppGroups[274].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[275]) { foreach ($group in $AppGroups[275].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[276]) { foreach ($group in $AppGroups[276].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[277]) { foreach ($group in $AppGroups[277].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[278]) { foreach ($group in $AppGroups[278].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[279]) { foreach ($group in $AppGroups[279].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[280]) { foreach ($group in $AppGroups[280].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[281]) { foreach ($group in $AppGroups[281].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[282]) { foreach ($group in $AppGroups[282].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[283]) { foreach ($group in $AppGroups[283].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[284]) { foreach ($group in $AppGroups[284].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[285]) { foreach ($group in $AppGroups[285].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[286]) { foreach ($group in $AppGroups[286].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[287]) { foreach ($group in $AppGroups[287].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[288]) { foreach ($group in $AppGroups[288].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[289]) { foreach ($group in $AppGroups[289].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[290]) { foreach ($group in $AppGroups[290].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[291]) { foreach ($group in $AppGroups[291].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[292]) { foreach ($group in $AppGroups[292].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[293]) { foreach ($group in $AppGroups[293].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[294]) { foreach ($group in $AppGroups[294].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[295]) { foreach ($group in $AppGroups[295].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[296]) { foreach ($group in $AppGroups[296].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[297]) { foreach ($group in $AppGroups[297].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[298]) { foreach ($group in $AppGroups[298].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[299]) { foreach ($group in $AppGroups[299].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[300]) { foreach ($group in $AppGroups[300].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[301]) { foreach ($group in $AppGroups[301].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[302]) { foreach ($group in $AppGroups[302].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[303]) { foreach ($group in $AppGroups[303].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[304]) { foreach ($group in $AppGroups[304].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[305]) { foreach ($group in $AppGroups[305].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[306]) { foreach ($group in $AppGroups[306].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[307]) { foreach ($group in $AppGroups[307].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[308]) { foreach ($group in $AppGroups[308].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[309]) { foreach ($group in $AppGroups[309].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[310]) { foreach ($group in $AppGroups[310].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[311]) { foreach ($group in $AppGroups[311].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[312]) { foreach ($group in $AppGroups[312].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[313]) { foreach ($group in $AppGroups[313].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[314]) { foreach ($group in $AppGroups[314].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[315]) { foreach ($group in $AppGroups[315].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[316]) { foreach ($group in $AppGroups[316].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[317]) { foreach ($group in $AppGroups[317].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[318]) { foreach ($group in $AppGroups[318].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[319]) { foreach ($group in $AppGroups[319].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[320]) { foreach ($group in $AppGroups[320].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[321]) { foreach ($group in $AppGroups[321].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[322]) { foreach ($group in $AppGroups[322].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[323]) { foreach ($group in $AppGroups[323].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[324]) { foreach ($group in $AppGroups[324].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[325]) { foreach ($group in $AppGroups[325].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[326]) { foreach ($group in $AppGroups[326].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[327]) { foreach ($group in $AppGroups[327].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[328]) { foreach ($group in $AppGroups[328].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[329]) { foreach ($group in $AppGroups[329].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[330]) { foreach ($group in $AppGroups[330].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[331]) { foreach ($group in $AppGroups[331].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[332]) { foreach ($group in $AppGroups[332].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[333]) { foreach ($group in $AppGroups[333].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[334]) { foreach ($group in $AppGroups[334].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[335]) { foreach ($group in $AppGroups[335].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[336]) { foreach ($group in $AppGroups[336].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[337]) { foreach ($group in $AppGroups[337].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[338]) { foreach ($group in $AppGroups[338].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[339]) { foreach ($group in $AppGroups[339].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[340]) { foreach ($group in $AppGroups[340].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[341]) { foreach ($group in $AppGroups[341].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[342]) { foreach ($group in $AppGroups[342].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[343]) { foreach ($group in $AppGroups[343].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[344]) { foreach ($group in $AppGroups[344].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[345]) { foreach ($group in $AppGroups[345].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[346]) { foreach ($group in $AppGroups[346].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[347]) { foreach ($group in $AppGroups[347].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[348]) { foreach ($group in $AppGroups[348].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[349]) { foreach ($group in $AppGroups[349].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[350]) { foreach ($group in $AppGroups[350].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[351]) { foreach ($group in $AppGroups[351].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[352]) { foreach ($group in $AppGroups[352].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[353]) { foreach ($group in $AppGroups[353].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[354]) { foreach ($group in $AppGroups[354].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[355]) { foreach ($group in $AppGroups[355].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[356]) { foreach ($group in $AppGroups[356].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[357]) { foreach ($group in $AppGroups[357].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[358]) { foreach ($group in $AppGroups[358].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[359]) { foreach ($group in $AppGroups[359].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[360]) { foreach ($group in $AppGroups[360].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[361]) { foreach ($group in $AppGroups[361].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[362]) { foreach ($group in $AppGroups[362].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[363]) { foreach ($group in $AppGroups[363].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[364]) { foreach ($group in $AppGroups[364].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[365]) { foreach ($group in $AppGroups[365].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[366]) { foreach ($group in $AppGroups[366].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[367]) { foreach ($group in $AppGroups[367].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[368]) { foreach ($group in $AppGroups[368].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[369]) { foreach ($group in $AppGroups[369].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[370]) { foreach ($group in $AppGroups[370].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[371]) { foreach ($group in $AppGroups[371].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[372]) { foreach ($group in $AppGroups[372].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[373]) { foreach ($group in $AppGroups[373].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[374]) { foreach ($group in $AppGroups[374].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[375]) { foreach ($group in $AppGroups[375].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[376]) { foreach ($group in $AppGroups[376].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[377]) { foreach ($group in $AppGroups[377].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[378]) { foreach ($group in $AppGroups[378].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[379]) { foreach ($group in $AppGroups[379].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[380]) { foreach ($group in $AppGroups[380].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[381]) { foreach ($group in $AppGroups[381].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[382]) { foreach ($group in $AppGroups[382].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[383]) { foreach ($group in $AppGroups[383].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[384]) { foreach ($group in $AppGroups[384].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[385]) { foreach ($group in $AppGroups[385].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[386]) { foreach ($group in $AppGroups[386].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[387]) { foreach ($group in $AppGroups[387].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[388]) { foreach ($group in $AppGroups[388].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[389]) { foreach ($group in $AppGroups[389].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[390]) { foreach ($group in $AppGroups[390].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[391]) { foreach ($group in $AppGroups[391].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[392]) { foreach ($group in $AppGroups[392].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[393]) { foreach ($group in $AppGroups[393].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[394]) { foreach ($group in $AppGroups[394].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[395]) { foreach ($group in $AppGroups[395].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[396]) { foreach ($group in $AppGroups[396].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[397]) { foreach ($group in $AppGroups[397].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[398]) { foreach ($group in $AppGroups[398].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[399]) { foreach ($group in $AppGroups[399].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[400]) { foreach ($group in $AppGroups[400].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[401]) { foreach ($group in $AppGroups[401].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[402]) { foreach ($group in $AppGroups[402].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[403]) { foreach ($group in $AppGroups[403].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[404]) { foreach ($group in $AppGroups[404].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[405]) { foreach ($group in $AppGroups[405].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[406]) { foreach ($group in $AppGroups[406].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[407]) { foreach ($group in $AppGroups[407].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[408]) { foreach ($group in $AppGroups[408].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[409]) { foreach ($group in $AppGroups[409].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[410]) { foreach ($group in $AppGroups[410].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[411]) { foreach ($group in $AppGroups[411].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[412]) { foreach ($group in $AppGroups[412].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[413]) { foreach ($group in $AppGroups[413].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[414]) { foreach ($group in $AppGroups[414].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[415]) { foreach ($group in $AppGroups[415].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[416]) { foreach ($group in $AppGroups[416].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[417]) { foreach ($group in $AppGroups[417].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[418]) { foreach ($group in $AppGroups[418].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[419]) { foreach ($group in $AppGroups[419].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[420]) { foreach ($group in $AppGroups[420].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[421]) { foreach ($group in $AppGroups[421].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[422]) { foreach ($group in $AppGroups[422].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[423]) { foreach ($group in $AppGroups[423].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[424]) { foreach ($group in $AppGroups[424].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[425]) { foreach ($group in $AppGroups[425].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[426]) { foreach ($group in $AppGroups[426].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[427]) { foreach ($group in $AppGroups[427].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[428]) { foreach ($group in $AppGroups[428].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[429]) { foreach ($group in $AppGroups[429].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[430]) { foreach ($group in $AppGroups[430].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[431]) { foreach ($group in $AppGroups[431].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[432]) { foreach ($group in $AppGroups[432].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[433]) { foreach ($group in $AppGroups[433].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[434]) { foreach ($group in $AppGroups[434].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[435]) { foreach ($group in $AppGroups[435].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[436]) { foreach ($group in $AppGroups[436].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[437]) { foreach ($group in $AppGroups[437].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[438]) { foreach ($group in $AppGroups[438].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[439]) { foreach ($group in $AppGroups[439].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[440]) { foreach ($group in $AppGroups[440].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[441]) { foreach ($group in $AppGroups[441].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[442]) { foreach ($group in $AppGroups[442].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[443]) { foreach ($group in $AppGroups[443].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[444]) { foreach ($group in $AppGroups[444].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[445]) { foreach ($group in $AppGroups[445].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[446]) { foreach ($group in $AppGroups[446].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[447]) { foreach ($group in $AppGroups[447].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[448]) { foreach ($group in $AppGroups[448].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[449]) { foreach ($group in $AppGroups[449].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[450]) { foreach ($group in $AppGroups[450].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[451]) { foreach ($group in $AppGroups[451].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[452]) { foreach ($group in $AppGroups[452].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[453]) { foreach ($group in $AppGroups[453].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[454]) { foreach ($group in $AppGroups[454].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[455]) { foreach ($group in $AppGroups[455].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[456]) { foreach ($group in $AppGroups[456].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[457]) { foreach ($group in $AppGroups[457].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[458]) { foreach ($group in $AppGroups[458].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[459]) { foreach ($group in $AppGroups[459].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[460]) { foreach ($group in $AppGroups[460].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[461]) { foreach ($group in $AppGroups[461].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[462]) { foreach ($group in $AppGroups[462].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[463]) { foreach ($group in $AppGroups[463].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[464]) { foreach ($group in $AppGroups[464].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[465]) { foreach ($group in $AppGroups[465].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[466]) { foreach ($group in $AppGroups[466].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[467]) { foreach ($group in $AppGroups[467].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[468]) { foreach ($group in $AppGroups[468].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[469]) { foreach ($group in $AppGroups[469].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[470]) { foreach ($group in $AppGroups[470].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[471]) { foreach ($group in $AppGroups[471].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[472]) { foreach ($group in $AppGroups[472].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[473]) { foreach ($group in $AppGroups[473].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[474]) { foreach ($group in $AppGroups[474].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[475]) { foreach ($group in $AppGroups[475].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[476]) { foreach ($group in $AppGroups[476].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[477]) { foreach ($group in $AppGroups[477].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[478]) { foreach ($group in $AppGroups[478].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[479]) { foreach ($group in $AppGroups[479].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[480]) { foreach ($group in $AppGroups[480].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[481]) { foreach ($group in $AppGroups[481].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[482]) { foreach ($group in $AppGroups[482].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[483]) { foreach ($group in $AppGroups[483].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[484]) { foreach ($group in $AppGroups[484].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[485]) { foreach ($group in $AppGroups[485].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[486]) { foreach ($group in $AppGroups[486].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[487]) { foreach ($group in $AppGroups[487].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[488]) { foreach ($group in $AppGroups[488].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[489]) { foreach ($group in $AppGroups[489].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[490]) { foreach ($group in $AppGroups[490].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[491]) { foreach ($group in $AppGroups[491].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[492]) { foreach ($group in $AppGroups[492].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[493]) { foreach ($group in $AppGroups[493].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[494]) { foreach ($group in $AppGroups[494].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[495]) { foreach ($group in $AppGroups[495].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[496]) { foreach ($group in $AppGroups[496].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[497]) { foreach ($group in $AppGroups[497].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[498]) { foreach ($group in $AppGroups[498].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[499]) { foreach ($group in $AppGroups[499].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[500]) { foreach ($group in $AppGroups[500].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[501]) { foreach ($group in $AppGroups[501].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[502]) { foreach ($group in $AppGroups[502].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[503]) { foreach ($group in $AppGroups[503].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[504]) { foreach ($group in $AppGroups[504].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[505]) { foreach ($group in $AppGroups[505].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[506]) { foreach ($group in $AppGroups[506].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[507]) { foreach ($group in $AppGroups[507].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[508]) { foreach ($group in $AppGroups[508].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[509]) { foreach ($group in $AppGroups[509].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[510]) { foreach ($group in $AppGroups[510].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[511]) { foreach ($group in $AppGroups[511].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[512]) { foreach ($group in $AppGroups[512].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[513]) { foreach ($group in $AppGroups[513].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[514]) { foreach ($group in $AppGroups[514].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[515]) { foreach ($group in $AppGroups[515].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[516]) { foreach ($group in $AppGroups[516].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[517]) { foreach ($group in $AppGroups[517].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[518]) { foreach ($group in $AppGroups[518].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[519]) { foreach ($group in $AppGroups[519].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[520]) { foreach ($group in $AppGroups[520].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[521]) { foreach ($group in $AppGroups[521].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[522]) { foreach ($group in $AppGroups[522].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[523]) { foreach ($group in $AppGroups[523].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[524]) { foreach ($group in $AppGroups[524].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[525]) { foreach ($group in $AppGroups[525].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[526]) { foreach ($group in $AppGroups[526].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[527]) { foreach ($group in $AppGroups[527].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[528]) { foreach ($group in $AppGroups[528].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[529]) { foreach ($group in $AppGroups[529].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[530]) { foreach ($group in $AppGroups[530].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[531]) { foreach ($group in $AppGroups[531].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[532]) { foreach ($group in $AppGroups[532].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[533]) { foreach ($group in $AppGroups[533].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[534]) { foreach ($group in $AppGroups[534].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[535]) { foreach ($group in $AppGroups[535].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[536]) { foreach ($group in $AppGroups[536].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[537]) { foreach ($group in $AppGroups[537].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[538]) { foreach ($group in $AppGroups[538].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[539]) { foreach ($group in $AppGroups[539].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[540]) { foreach ($group in $AppGroups[540].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[541]) { foreach ($group in $AppGroups[541].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[542]) { foreach ($group in $AppGroups[542].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[543]) { foreach ($group in $AppGroups[543].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[544]) { foreach ($group in $AppGroups[544].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[545]) { foreach ($group in $AppGroups[545].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[546]) { foreach ($group in $AppGroups[546].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[547]) { foreach ($group in $AppGroups[547].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[548]) { foreach ($group in $AppGroups[548].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[549]) { foreach ($group in $AppGroups[549].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[550]) { foreach ($group in $AppGroups[550].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[551]) { foreach ($group in $AppGroups[551].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[552]) { foreach ($group in $AppGroups[552].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[553]) { foreach ($group in $AppGroups[553].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[554]) { foreach ($group in $AppGroups[554].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[555]) { foreach ($group in $AppGroups[555].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[556]) { foreach ($group in $AppGroups[556].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[557]) { foreach ($group in $AppGroups[557].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[558]) { foreach ($group in $AppGroups[558].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[559]) { foreach ($group in $AppGroups[559].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[560]) { foreach ($group in $AppGroups[560].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[561]) { foreach ($group in $AppGroups[561].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[562]) { foreach ($group in $AppGroups[562].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[563]) { foreach ($group in $AppGroups[563].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[564]) { foreach ($group in $AppGroups[564].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[565]) { foreach ($group in $AppGroups[565].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[566]) { foreach ($group in $AppGroups[566].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[567]) { foreach ($group in $AppGroups[567].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[568]) { foreach ($group in $AppGroups[568].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[569]) { foreach ($group in $AppGroups[569].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[570]) { foreach ($group in $AppGroups[570].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[571]) { foreach ($group in $AppGroups[571].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[572]) { foreach ($group in $AppGroups[572].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[573]) { foreach ($group in $AppGroups[573].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[574]) { foreach ($group in $AppGroups[574].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[575]) { foreach ($group in $AppGroups[575].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[576]) { foreach ($group in $AppGroups[576].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[577]) { foreach ($group in $AppGroups[577].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[578]) { foreach ($group in $AppGroups[578].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[579]) { foreach ($group in $AppGroups[579].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[580]) { foreach ($group in $AppGroups[580].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[581]) { foreach ($group in $AppGroups[581].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[582]) { foreach ($group in $AppGroups[582].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[583]) { foreach ($group in $AppGroups[583].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[584]) { foreach ($group in $AppGroups[584].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[585]) { foreach ($group in $AppGroups[585].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[586]) { foreach ($group in $AppGroups[586].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[587]) { foreach ($group in $AppGroups[587].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[588]) { foreach ($group in $AppGroups[588].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[589]) { foreach ($group in $AppGroups[589].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[590]) { foreach ($group in $AppGroups[590].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[591]) { foreach ($group in $AppGroups[591].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[592]) { foreach ($group in $AppGroups[592].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[593]) { foreach ($group in $AppGroups[593].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[594]) { foreach ($group in $AppGroups[594].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[595]) { foreach ($group in $AppGroups[595].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[596]) { foreach ($group in $AppGroups[596].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[597]) { foreach ($group in $AppGroups[597].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[598]) { foreach ($group in $AppGroups[598].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[599]) { foreach ($group in $AppGroups[599].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[600]) { foreach ($group in $AppGroups[600].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[601]) { foreach ($group in $AppGroups[601].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[602]) { foreach ($group in $AppGroups[602].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[603]) { foreach ($group in $AppGroups[603].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[604]) { foreach ($group in $AppGroups[604].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[605]) { foreach ($group in $AppGroups[605].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[606]) { foreach ($group in $AppGroups[606].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[607]) { foreach ($group in $AppGroups[607].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[608]) { foreach ($group in $AppGroups[608].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[609]) { foreach ($group in $AppGroups[609].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[610]) { foreach ($group in $AppGroups[610].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[611]) { foreach ($group in $AppGroups[611].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[612]) { foreach ($group in $AppGroups[612].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[613]) { foreach ($group in $AppGroups[613].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[614]) { foreach ($group in $AppGroups[614].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[615]) { foreach ($group in $AppGroups[615].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[616]) { foreach ($group in $AppGroups[616].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[617]) { foreach ($group in $AppGroups[617].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[618]) { foreach ($group in $AppGroups[618].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[619]) { foreach ($group in $AppGroups[619].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[620]) { foreach ($group in $AppGroups[620].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[621]) { foreach ($group in $AppGroups[621].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[622]) { foreach ($group in $AppGroups[622].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[623]) { foreach ($group in $AppGroups[623].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[624]) { foreach ($group in $AppGroups[624].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[625]) { foreach ($group in $AppGroups[625].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[626]) { foreach ($group in $AppGroups[626].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[627]) { foreach ($group in $AppGroups[627].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[628]) { foreach ($group in $AppGroups[628].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[629]) { foreach ($group in $AppGroups[629].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[630]) { foreach ($group in $AppGroups[630].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[631]) { foreach ($group in $AppGroups[631].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[632]) { foreach ($group in $AppGroups[632].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[633]) { foreach ($group in $AppGroups[633].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[634]) { foreach ($group in $AppGroups[634].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[635]) { foreach ($group in $AppGroups[635].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[636]) { foreach ($group in $AppGroups[636].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[637]) { foreach ($group in $AppGroups[637].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[638]) { foreach ($group in $AppGroups[638].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[639]) { foreach ($group in $AppGroups[639].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[640]) { foreach ($group in $AppGroups[640].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[641]) { foreach ($group in $AppGroups[641].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[642]) { foreach ($group in $AppGroups[642].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[643]) { foreach ($group in $AppGroups[643].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[644]) { foreach ($group in $AppGroups[644].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[645]) { foreach ($group in $AppGroups[645].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[646]) { foreach ($group in $AppGroups[646].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[647]) { foreach ($group in $AppGroups[647].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[648]) { foreach ($group in $AppGroups[648].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[649]) { foreach ($group in $AppGroups[649].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[650]) { foreach ($group in $AppGroups[650].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[651]) { foreach ($group in $AppGroups[651].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[652]) { foreach ($group in $AppGroups[652].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[653]) { foreach ($group in $AppGroups[653].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[654]) { foreach ($group in $AppGroups[654].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[655]) { foreach ($group in $AppGroups[655].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[656]) { foreach ($group in $AppGroups[656].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[657]) { foreach ($group in $AppGroups[657].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[658]) { foreach ($group in $AppGroups[658].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[659]) { foreach ($group in $AppGroups[659].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[660]) { foreach ($group in $AppGroups[660].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[661]) { foreach ($group in $AppGroups[661].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[662]) { foreach ($group in $AppGroups[662].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[663]) { foreach ($group in $AppGroups[663].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[664]) { foreach ($group in $AppGroups[664].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[665]) { foreach ($group in $AppGroups[665].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[666]) { foreach ($group in $AppGroups[666].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[667]) { foreach ($group in $AppGroups[667].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[668]) { foreach ($group in $AppGroups[668].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[669]) { foreach ($group in $AppGroups[669].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[670]) { foreach ($group in $AppGroups[670].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[671]) { foreach ($group in $AppGroups[671].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[672]) { foreach ($group in $AppGroups[672].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[673]) { foreach ($group in $AppGroups[673].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[674]) { foreach ($group in $AppGroups[674].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[675]) { foreach ($group in $AppGroups[675].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[676]) { foreach ($group in $AppGroups[676].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[677]) { foreach ($group in $AppGroups[677].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[678]) { foreach ($group in $AppGroups[678].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[679]) { foreach ($group in $AppGroups[679].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[680]) { foreach ($group in $AppGroups[680].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[681]) { foreach ($group in $AppGroups[681].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[682]) { foreach ($group in $AppGroups[682].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[683]) { foreach ($group in $AppGroups[683].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[684]) { foreach ($group in $AppGroups[684].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[685]) { foreach ($group in $AppGroups[685].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[686]) { foreach ($group in $AppGroups[686].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[687]) { foreach ($group in $AppGroups[687].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[688]) { foreach ($group in $AppGroups[688].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[689]) { foreach ($group in $AppGroups[689].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[690]) { foreach ($group in $AppGroups[690].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[691]) { foreach ($group in $AppGroups[691].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[692]) { foreach ($group in $AppGroups[692].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[693]) { foreach ($group in $AppGroups[693].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[694]) { foreach ($group in $AppGroups[694].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[695]) { foreach ($group in $AppGroups[695].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[696]) { foreach ($group in $AppGroups[696].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[697]) { foreach ($group in $AppGroups[697].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[698]) { foreach ($group in $AppGroups[698].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[699]) { foreach ($group in $AppGroups[699].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[700]) { foreach ($group in $AppGroups[700].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[701]) { foreach ($group in $AppGroups[701].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[702]) { foreach ($group in $AppGroups[702].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[703]) { foreach ($group in $AppGroups[703].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[704]) { foreach ($group in $AppGroups[704].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[705]) { foreach ($group in $AppGroups[705].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[706]) { foreach ($group in $AppGroups[706].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[707]) { foreach ($group in $AppGroups[707].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[708]) { foreach ($group in $AppGroups[708].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[709]) { foreach ($group in $AppGroups[709].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[710]) { foreach ($group in $AppGroups[710].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[711]) { foreach ($group in $AppGroups[711].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[712]) { foreach ($group in $AppGroups[712].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[713]) { foreach ($group in $AppGroups[713].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[714]) { foreach ($group in $AppGroups[714].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[715]) { foreach ($group in $AppGroups[715].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[716]) { foreach ($group in $AppGroups[716].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[717]) { foreach ($group in $AppGroups[717].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[718]) { foreach ($group in $AppGroups[718].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[719]) { foreach ($group in $AppGroups[719].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[720]) { foreach ($group in $AppGroups[720].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[721]) { foreach ($group in $AppGroups[721].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[722]) { foreach ($group in $AppGroups[722].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[723]) { foreach ($group in $AppGroups[723].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[724]) { foreach ($group in $AppGroups[724].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[725]) { foreach ($group in $AppGroups[725].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[726]) { foreach ($group in $AppGroups[726].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[727]) { foreach ($group in $AppGroups[727].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[728]) { foreach ($group in $AppGroups[728].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[729]) { foreach ($group in $AppGroups[729].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[730]) { foreach ($group in $AppGroups[730].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[731]) { foreach ($group in $AppGroups[731].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[732]) { foreach ($group in $AppGroups[732].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[733]) { foreach ($group in $AppGroups[733].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[734]) { foreach ($group in $AppGroups[734].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[735]) { foreach ($group in $AppGroups[735].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[736]) { foreach ($group in $AppGroups[736].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[737]) { foreach ($group in $AppGroups[737].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[738]) { foreach ($group in $AppGroups[738].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[739]) { foreach ($group in $AppGroups[739].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[740]) { foreach ($group in $AppGroups[740].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[741]) { foreach ($group in $AppGroups[741].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[742]) { foreach ($group in $AppGroups[742].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[743]) { foreach ($group in $AppGroups[743].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[744]) { foreach ($group in $AppGroups[744].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[745]) { foreach ($group in $AppGroups[745].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[746]) { foreach ($group in $AppGroups[746].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[747]) { foreach ($group in $AppGroups[747].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[748]) { foreach ($group in $AppGroups[748].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[749]) { foreach ($group in $AppGroups[749].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[750]) { foreach ($group in $AppGroups[750].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[751]) { foreach ($group in $AppGroups[751].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[752]) { foreach ($group in $AppGroups[752].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[753]) { foreach ($group in $AppGroups[753].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[754]) { foreach ($group in $AppGroups[754].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[755]) { foreach ($group in $AppGroups[755].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[756]) { foreach ($group in $AppGroups[756].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[757]) { foreach ($group in $AppGroups[757].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[758]) { foreach ($group in $AppGroups[758].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[759]) { foreach ($group in $AppGroups[759].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[760]) { foreach ($group in $AppGroups[760].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[761]) { foreach ($group in $AppGroups[761].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[762]) { foreach ($group in $AppGroups[762].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[763]) { foreach ($group in $AppGroups[763].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[764]) { foreach ($group in $AppGroups[764].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[765]) { foreach ($group in $AppGroups[765].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[766]) { foreach ($group in $AppGroups[766].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[767]) { foreach ($group in $AppGroups[767].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[768]) { foreach ($group in $AppGroups[768].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[769]) { foreach ($group in $AppGroups[769].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[770]) { foreach ($group in $AppGroups[770].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[771]) { foreach ($group in $AppGroups[771].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[772]) { foreach ($group in $AppGroups[772].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[773]) { foreach ($group in $AppGroups[773].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[774]) { foreach ($group in $AppGroups[774].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[775]) { foreach ($group in $AppGroups[775].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[776]) { foreach ($group in $AppGroups[776].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[777]) { foreach ($group in $AppGroups[777].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[778]) { foreach ($group in $AppGroups[778].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[779]) { foreach ($group in $AppGroups[779].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[780]) { foreach ($group in $AppGroups[780].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[781]) { foreach ($group in $AppGroups[781].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[782]) { foreach ($group in $AppGroups[782].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[783]) { foreach ($group in $AppGroups[783].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[784]) { foreach ($group in $AppGroups[784].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[785]) { foreach ($group in $AppGroups[785].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[786]) { foreach ($group in $AppGroups[786].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[787]) { foreach ($group in $AppGroups[787].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[788]) { foreach ($group in $AppGroups[788].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[789]) { foreach ($group in $AppGroups[789].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[790]) { foreach ($group in $AppGroups[790].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[791]) { foreach ($group in $AppGroups[791].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[792]) { foreach ($group in $AppGroups[792].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[793]) { foreach ($group in $AppGroups[793].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[794]) { foreach ($group in $AppGroups[794].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[795]) { foreach ($group in $AppGroups[795].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[796]) { foreach ($group in $AppGroups[796].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[797]) { foreach ($group in $AppGroups[797].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[798]) { foreach ($group in $AppGroups[798].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[799]) { foreach ($group in $AppGroups[799].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[800]) { foreach ($group in $AppGroups[800].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[801]) { foreach ($group in $AppGroups[801].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[802]) { foreach ($group in $AppGroups[802].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[803]) { foreach ($group in $AppGroups[803].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[804]) { foreach ($group in $AppGroups[804].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[805]) { foreach ($group in $AppGroups[805].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[806]) { foreach ($group in $AppGroups[806].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[807]) { foreach ($group in $AppGroups[807].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[808]) { foreach ($group in $AppGroups[808].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[809]) { foreach ($group in $AppGroups[809].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[810]) { foreach ($group in $AppGroups[810].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[811]) { foreach ($group in $AppGroups[811].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[812]) { foreach ($group in $AppGroups[812].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[813]) { foreach ($group in $AppGroups[813].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[814]) { foreach ($group in $AppGroups[814].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[815]) { foreach ($group in $AppGroups[815].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[816]) { foreach ($group in $AppGroups[816].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[817]) { foreach ($group in $AppGroups[817].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[818]) { foreach ($group in $AppGroups[818].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[819]) { foreach ($group in $AppGroups[819].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[820]) { foreach ($group in $AppGroups[820].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[821]) { foreach ($group in $AppGroups[821].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[822]) { foreach ($group in $AppGroups[822].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[823]) { foreach ($group in $AppGroups[823].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[824]) { foreach ($group in $AppGroups[824].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[825]) { foreach ($group in $AppGroups[825].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[826]) { foreach ($group in $AppGroups[826].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[827]) { foreach ($group in $AppGroups[827].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[828]) { foreach ($group in $AppGroups[828].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[829]) { foreach ($group in $AppGroups[829].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[830]) { foreach ($group in $AppGroups[830].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[831]) { foreach ($group in $AppGroups[831].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[832]) { foreach ($group in $AppGroups[832].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[833]) { foreach ($group in $AppGroups[833].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[834]) { foreach ($group in $AppGroups[834].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[835]) { foreach ($group in $AppGroups[835].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[836]) { foreach ($group in $AppGroups[836].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[837]) { foreach ($group in $AppGroups[837].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[838]) { foreach ($group in $AppGroups[838].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[839]) { foreach ($group in $AppGroups[839].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[840]) { foreach ($group in $AppGroups[840].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[841]) { foreach ($group in $AppGroups[841].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[842]) { foreach ($group in $AppGroups[842].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[843]) { foreach ($group in $AppGroups[843].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[844]) { foreach ($group in $AppGroups[844].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[845]) { foreach ($group in $AppGroups[845].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[846]) { foreach ($group in $AppGroups[846].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[847]) { foreach ($group in $AppGroups[847].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[848]) { foreach ($group in $AppGroups[848].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[849]) { foreach ($group in $AppGroups[849].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[850]) { foreach ($group in $AppGroups[850].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[851]) { foreach ($group in $AppGroups[851].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[852]) { foreach ($group in $AppGroups[852].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[853]) { foreach ($group in $AppGroups[853].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[854]) { foreach ($group in $AppGroups[854].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[855]) { foreach ($group in $AppGroups[855].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[856]) { foreach ($group in $AppGroups[856].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[857]) { foreach ($group in $AppGroups[857].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[858]) { foreach ($group in $AppGroups[858].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[859]) { foreach ($group in $AppGroups[859].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[860]) { foreach ($group in $AppGroups[860].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[861]) { foreach ($group in $AppGroups[861].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[862]) { foreach ($group in $AppGroups[862].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[863]) { foreach ($group in $AppGroups[863].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[864]) { foreach ($group in $AppGroups[864].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[865]) { foreach ($group in $AppGroups[865].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[866]) { foreach ($group in $AppGroups[866].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[867]) { foreach ($group in $AppGroups[867].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[868]) { foreach ($group in $AppGroups[868].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[869]) { foreach ($group in $AppGroups[869].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[870]) { foreach ($group in $AppGroups[870].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[871]) { foreach ($group in $AppGroups[871].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[872]) { foreach ($group in $AppGroups[872].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[873]) { foreach ($group in $AppGroups[873].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[874]) { foreach ($group in $AppGroups[874].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[875]) { foreach ($group in $AppGroups[875].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[876]) { foreach ($group in $AppGroups[876].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[877]) { foreach ($group in $AppGroups[877].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[878]) { foreach ($group in $AppGroups[878].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[879]) { foreach ($group in $AppGroups[879].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[880]) { foreach ($group in $AppGroups[880].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[881]) { foreach ($group in $AppGroups[881].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[882]) { foreach ($group in $AppGroups[882].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[883]) { foreach ($group in $AppGroups[883].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[884]) { foreach ($group in $AppGroups[884].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[885]) { foreach ($group in $AppGroups[885].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[886]) { foreach ($group in $AppGroups[886].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[887]) { foreach ($group in $AppGroups[887].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[888]) { foreach ($group in $AppGroups[888].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[889]) { foreach ($group in $AppGroups[889].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[890]) { foreach ($group in $AppGroups[890].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[891]) { foreach ($group in $AppGroups[891].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[892]) { foreach ($group in $AppGroups[892].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[893]) { foreach ($group in $AppGroups[893].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[894]) { foreach ($group in $AppGroups[894].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[895]) { foreach ($group in $AppGroups[895].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[896]) { foreach ($group in $AppGroups[896].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[897]) { foreach ($group in $AppGroups[897].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[898]) { foreach ($group in $AppGroups[898].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[899]) { foreach ($group in $AppGroups[899].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[900]) { foreach ($group in $AppGroups[900].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[901]) { foreach ($group in $AppGroups[901].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[902]) { foreach ($group in $AppGroups[902].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[903]) { foreach ($group in $AppGroups[903].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[904]) { foreach ($group in $AppGroups[904].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[905]) { foreach ($group in $AppGroups[905].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[906]) { foreach ($group in $AppGroups[906].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[907]) { foreach ($group in $AppGroups[907].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[908]) { foreach ($group in $AppGroups[908].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[909]) { foreach ($group in $AppGroups[909].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[910]) { foreach ($group in $AppGroups[910].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[911]) { foreach ($group in $AppGroups[911].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[912]) { foreach ($group in $AppGroups[912].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[913]) { foreach ($group in $AppGroups[913].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[914]) { foreach ($group in $AppGroups[914].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[915]) { foreach ($group in $AppGroups[915].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[916]) { foreach ($group in $AppGroups[916].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[917]) { foreach ($group in $AppGroups[917].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[918]) { foreach ($group in $AppGroups[918].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[919]) { foreach ($group in $AppGroups[919].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[920]) { foreach ($group in $AppGroups[920].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[921]) { foreach ($group in $AppGroups[921].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[922]) { foreach ($group in $AppGroups[922].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[923]) { foreach ($group in $AppGroups[923].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[924]) { foreach ($group in $AppGroups[924].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[925]) { foreach ($group in $AppGroups[925].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[926]) { foreach ($group in $AppGroups[926].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[927]) { foreach ($group in $AppGroups[927].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[928]) { foreach ($group in $AppGroups[928].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[929]) { foreach ($group in $AppGroups[929].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[930]) { foreach ($group in $AppGroups[930].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[931]) { foreach ($group in $AppGroups[931].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[932]) { foreach ($group in $AppGroups[932].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[933]) { foreach ($group in $AppGroups[933].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[934]) { foreach ($group in $AppGroups[934].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[935]) { foreach ($group in $AppGroups[935].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[936]) { foreach ($group in $AppGroups[936].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[937]) { foreach ($group in $AppGroups[937].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[938]) { foreach ($group in $AppGroups[938].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[939]) { foreach ($group in $AppGroups[939].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[940]) { foreach ($group in $AppGroups[940].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[941]) { foreach ($group in $AppGroups[941].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[942]) { foreach ($group in $AppGroups[942].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[943]) { foreach ($group in $AppGroups[943].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[944]) { foreach ($group in $AppGroups[944].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[945]) { foreach ($group in $AppGroups[945].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[946]) { foreach ($group in $AppGroups[946].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[947]) { foreach ($group in $AppGroups[947].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[948]) { foreach ($group in $AppGroups[948].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[949]) { foreach ($group in $AppGroups[949].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[950]) { foreach ($group in $AppGroups[950].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[951]) { foreach ($group in $AppGroups[951].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[952]) { foreach ($group in $AppGroups[952].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[953]) { foreach ($group in $AppGroups[953].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[954]) { foreach ($group in $AppGroups[954].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[955]) { foreach ($group in $AppGroups[955].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[956]) { foreach ($group in $AppGroups[956].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[957]) { foreach ($group in $AppGroups[957].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[958]) { foreach ($group in $AppGroups[958].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[959]) { foreach ($group in $AppGroups[959].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[960]) { foreach ($group in $AppGroups[960].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[961]) { foreach ($group in $AppGroups[961].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[962]) { foreach ($group in $AppGroups[962].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[963]) { foreach ($group in $AppGroups[963].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[964]) { foreach ($group in $AppGroups[964].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[965]) { foreach ($group in $AppGroups[965].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[966]) { foreach ($group in $AppGroups[966].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[967]) { foreach ($group in $AppGroups[967].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[968]) { foreach ($group in $AppGroups[968].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[969]) { foreach ($group in $AppGroups[969].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[970]) { foreach ($group in $AppGroups[970].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[971]) { foreach ($group in $AppGroups[971].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[972]) { foreach ($group in $AppGroups[972].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[973]) { foreach ($group in $AppGroups[973].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[974]) { foreach ($group in $AppGroups[974].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[975]) { foreach ($group in $AppGroups[975].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[976]) { foreach ($group in $AppGroups[976].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[977]) { foreach ($group in $AppGroups[977].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[978]) { foreach ($group in $AppGroups[978].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[979]) { foreach ($group in $AppGroups[979].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[980]) { foreach ($group in $AppGroups[980].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[981]) { foreach ($group in $AppGroups[981].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[982]) { foreach ($group in $AppGroups[982].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[983]) { foreach ($group in $AppGroups[983].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[984]) { foreach ($group in $AppGroups[984].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[985]) { foreach ($group in $AppGroups[985].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[986]) { foreach ($group in $AppGroups[986].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[987]) { foreach ($group in $AppGroups[987].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[988]) { foreach ($group in $AppGroups[988].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[989]) { foreach ($group in $AppGroups[989].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[990]) { foreach ($group in $AppGroups[990].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[991]) { foreach ($group in $AppGroups[991].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[992]) { foreach ($group in $AppGroups[992].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[993]) { foreach ($group in $AppGroups[993].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[994]) { foreach ($group in $AppGroups[994].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[995]) { foreach ($group in $AppGroups[995].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[996]) { foreach ($group in $AppGroups[996].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[997]) { foreach ($group in $AppGroups[997].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[998]) { foreach ($group in $AppGroups[998].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[999]) { foreach ($group in $AppGroups[999].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }
        if ($User -like $AppUsers[1000]) { foreach ($group in $AppGroups[1000].Split(',')) {Add-ADGroupMember -Identity $group -Members $user} }

         }
    } 
    }
    # =============================================================================================================================================== #

    Start-Sleep -Seconds 5

    # === AddTo_AppsGroups_Computers ===
    $testpath = Test-Path "D:\PSInData\Appdist\Comp_Appdist_$date.csv"
    if ($testpath -eq $True)
    {    
    #Write-Host "NOTE! Please check Date variable before continueing" -ForegroundColor Cyan
    #Read-Host -Prompt "Press any key to continue..."

    #=== Variables ==================
    #$date = read-host "Enter date in format yyyyMMdd"
    $DCTieto = "wsdc003.ad.stockholm.se"
    $CompAppsList = "D:\PSInData\Appdist\Comp_Appdist_$date.csv"
    $data = Import-Csv -Header SamAccountName, AppGroup -Delimiter ";" -LiteralPath $CompAppsList
    $AppComp = $data.SamAccountName | select -Skip 1
    $AppGroupS = $data.AppGroup | select -Skip 1

    #$members = @($AppComp)

    foreach ($Comp in $AppComp)
    {
        #if($data -contains $Comp){
            # test script line
            #if ($Comp -like $AppComp[0]) { foreach ($group in $AppGroups[0].Split(',')) {Write-Host $group} } }

            #$comp = $c + "$"

            if ($Comp -like $AppComp[0]) { foreach ($group in $AppGroups[0].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[1]) { foreach ($group in $AppGroups[1].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[2]) { foreach ($group in $AppGroups[2].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[3]) { foreach ($group in $AppGroups[3].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[4]) { foreach ($group in $AppGroups[4].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[5]) { foreach ($group in $AppGroups[5].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[6]) { foreach ($group in $AppGroups[6].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[7]) { foreach ($group in $AppGroups[7].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[8]) { foreach ($group in $AppGroups[8].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[9]) { foreach ($group in $AppGroups[9].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[10]) { foreach ($group in $AppGroups[10].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[11]) { foreach ($group in $AppGroups[11].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[12]) { foreach ($group in $AppGroups[12].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[13]) { foreach ($group in $AppGroups[13].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[14]) { foreach ($group in $AppGroups[14].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[15]) { foreach ($group in $AppGroups[15].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[16]) { foreach ($group in $AppGroups[16].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[17]) { foreach ($group in $AppGroups[17].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[18]) { foreach ($group in $AppGroups[18].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[19]) { foreach ($group in $AppGroups[19].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[20]) { foreach ($group in $AppGroups[20].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[21]) { foreach ($group in $AppGroups[21].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[22]) { foreach ($group in $AppGroups[22].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[23]) { foreach ($group in $AppGroups[23].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[24]) { foreach ($group in $AppGroups[24].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[25]) { foreach ($group in $AppGroups[25].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[26]) { foreach ($group in $AppGroups[26].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[27]) { foreach ($group in $AppGroups[27].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[28]) { foreach ($group in $AppGroups[28].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[29]) { foreach ($group in $AppGroups[29].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[30]) { foreach ($group in $AppGroups[30].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[31]) { foreach ($group in $AppGroups[31].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[32]) { foreach ($group in $AppGroups[32].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[33]) { foreach ($group in $AppGroups[33].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[34]) { foreach ($group in $AppGroups[34].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[35]) { foreach ($group in $AppGroups[35].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[36]) { foreach ($group in $AppGroups[36].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[37]) { foreach ($group in $AppGroups[37].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[38]) { foreach ($group in $AppGroups[38].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[39]) { foreach ($group in $AppGroups[39].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[40]) { foreach ($group in $AppGroups[40].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[41]) { foreach ($group in $AppGroups[41].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[42]) { foreach ($group in $AppGroups[42].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[43]) { foreach ($group in $AppGroups[43].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[44]) { foreach ($group in $AppGroups[44].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[45]) { foreach ($group in $AppGroups[45].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[46]) { foreach ($group in $AppGroups[46].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[47]) { foreach ($group in $AppGroups[47].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[48]) { foreach ($group in $AppGroups[48].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[49]) { foreach ($group in $AppGroups[49].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[50]) { foreach ($group in $AppGroups[50].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[51]) { foreach ($group in $AppGroups[51].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[52]) { foreach ($group in $AppGroups[52].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[53]) { foreach ($group in $AppGroups[53].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[54]) { foreach ($group in $AppGroups[54].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[55]) { foreach ($group in $AppGroups[55].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[56]) { foreach ($group in $AppGroups[56].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[57]) { foreach ($group in $AppGroups[57].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[58]) { foreach ($group in $AppGroups[58].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[59]) { foreach ($group in $AppGroups[59].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[60]) { foreach ($group in $AppGroups[60].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[61]) { foreach ($group in $AppGroups[61].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[62]) { foreach ($group in $AppGroups[62].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[63]) { foreach ($group in $AppGroups[63].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[64]) { foreach ($group in $AppGroups[64].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[65]) { foreach ($group in $AppGroups[65].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[66]) { foreach ($group in $AppGroups[66].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[67]) { foreach ($group in $AppGroups[67].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[68]) { foreach ($group in $AppGroups[68].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[69]) { foreach ($group in $AppGroups[69].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[70]) { foreach ($group in $AppGroups[70].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[71]) { foreach ($group in $AppGroups[71].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[72]) { foreach ($group in $AppGroups[72].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[73]) { foreach ($group in $AppGroups[73].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[74]) { foreach ($group in $AppGroups[74].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[75]) { foreach ($group in $AppGroups[75].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[76]) { foreach ($group in $AppGroups[76].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[77]) { foreach ($group in $AppGroups[77].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[78]) { foreach ($group in $AppGroups[78].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[79]) { foreach ($group in $AppGroups[79].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[80]) { foreach ($group in $AppGroups[80].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[81]) { foreach ($group in $AppGroups[81].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[82]) { foreach ($group in $AppGroups[82].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[83]) { foreach ($group in $AppGroups[83].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[84]) { foreach ($group in $AppGroups[84].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[85]) { foreach ($group in $AppGroups[85].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[86]) { foreach ($group in $AppGroups[86].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[87]) { foreach ($group in $AppGroups[87].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[88]) { foreach ($group in $AppGroups[88].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[89]) { foreach ($group in $AppGroups[89].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[90]) { foreach ($group in $AppGroups[90].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[91]) { foreach ($group in $AppGroups[91].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[92]) { foreach ($group in $AppGroups[92].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[93]) { foreach ($group in $AppGroups[93].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[94]) { foreach ($group in $AppGroups[94].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[95]) { foreach ($group in $AppGroups[95].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[96]) { foreach ($group in $AppGroups[96].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[97]) { foreach ($group in $AppGroups[97].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[98]) { foreach ($group in $AppGroups[98].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[99]) { foreach ($group in $AppGroups[99].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[100]) { foreach ($group in $AppGroups[100].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[101]) { foreach ($group in $AppGroups[101].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[102]) { foreach ($group in $AppGroups[102].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[103]) { foreach ($group in $AppGroups[103].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[104]) { foreach ($group in $AppGroups[104].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[105]) { foreach ($group in $AppGroups[105].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[106]) { foreach ($group in $AppGroups[106].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[107]) { foreach ($group in $AppGroups[107].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[108]) { foreach ($group in $AppGroups[108].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[109]) { foreach ($group in $AppGroups[109].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[110]) { foreach ($group in $AppGroups[110].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[111]) { foreach ($group in $AppGroups[111].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[112]) { foreach ($group in $AppGroups[112].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[113]) { foreach ($group in $AppGroups[113].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[114]) { foreach ($group in $AppGroups[114].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[115]) { foreach ($group in $AppGroups[115].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[116]) { foreach ($group in $AppGroups[116].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[117]) { foreach ($group in $AppGroups[117].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[118]) { foreach ($group in $AppGroups[118].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[119]) { foreach ($group in $AppGroups[119].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[120]) { foreach ($group in $AppGroups[120].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[121]) { foreach ($group in $AppGroups[121].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[122]) { foreach ($group in $AppGroups[122].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[123]) { foreach ($group in $AppGroups[123].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[124]) { foreach ($group in $AppGroups[124].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[125]) { foreach ($group in $AppGroups[125].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[126]) { foreach ($group in $AppGroups[126].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[127]) { foreach ($group in $AppGroups[127].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[128]) { foreach ($group in $AppGroups[128].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[129]) { foreach ($group in $AppGroups[129].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[130]) { foreach ($group in $AppGroups[130].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[131]) { foreach ($group in $AppGroups[131].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[132]) { foreach ($group in $AppGroups[132].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[133]) { foreach ($group in $AppGroups[133].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[134]) { foreach ($group in $AppGroups[134].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[135]) { foreach ($group in $AppGroups[135].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[136]) { foreach ($group in $AppGroups[136].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[137]) { foreach ($group in $AppGroups[137].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[138]) { foreach ($group in $AppGroups[138].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[139]) { foreach ($group in $AppGroups[139].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[140]) { foreach ($group in $AppGroups[140].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[141]) { foreach ($group in $AppGroups[141].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[142]) { foreach ($group in $AppGroups[142].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[143]) { foreach ($group in $AppGroups[143].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[144]) { foreach ($group in $AppGroups[144].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[145]) { foreach ($group in $AppGroups[145].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[146]) { foreach ($group in $AppGroups[146].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[147]) { foreach ($group in $AppGroups[147].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[148]) { foreach ($group in $AppGroups[148].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[149]) { foreach ($group in $AppGroups[149].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[150]) { foreach ($group in $AppGroups[150].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[151]) { foreach ($group in $AppGroups[151].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[152]) { foreach ($group in $AppGroups[152].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[153]) { foreach ($group in $AppGroups[153].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[154]) { foreach ($group in $AppGroups[154].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[155]) { foreach ($group in $AppGroups[155].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[156]) { foreach ($group in $AppGroups[156].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[157]) { foreach ($group in $AppGroups[157].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[158]) { foreach ($group in $AppGroups[158].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[159]) { foreach ($group in $AppGroups[159].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[160]) { foreach ($group in $AppGroups[160].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[161]) { foreach ($group in $AppGroups[161].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[162]) { foreach ($group in $AppGroups[162].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[163]) { foreach ($group in $AppGroups[163].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[164]) { foreach ($group in $AppGroups[164].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[165]) { foreach ($group in $AppGroups[165].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[166]) { foreach ($group in $AppGroups[166].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[167]) { foreach ($group in $AppGroups[167].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[168]) { foreach ($group in $AppGroups[168].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[169]) { foreach ($group in $AppGroups[169].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[170]) { foreach ($group in $AppGroups[170].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[171]) { foreach ($group in $AppGroups[171].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[172]) { foreach ($group in $AppGroups[172].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[173]) { foreach ($group in $AppGroups[173].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[174]) { foreach ($group in $AppGroups[174].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[175]) { foreach ($group in $AppGroups[175].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[176]) { foreach ($group in $AppGroups[176].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[177]) { foreach ($group in $AppGroups[177].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[178]) { foreach ($group in $AppGroups[178].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[179]) { foreach ($group in $AppGroups[179].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[180]) { foreach ($group in $AppGroups[180].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[181]) { foreach ($group in $AppGroups[181].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[182]) { foreach ($group in $AppGroups[182].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[183]) { foreach ($group in $AppGroups[183].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[184]) { foreach ($group in $AppGroups[184].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[185]) { foreach ($group in $AppGroups[185].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[186]) { foreach ($group in $AppGroups[186].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[187]) { foreach ($group in $AppGroups[187].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[188]) { foreach ($group in $AppGroups[188].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[189]) { foreach ($group in $AppGroups[189].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[190]) { foreach ($group in $AppGroups[190].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[191]) { foreach ($group in $AppGroups[191].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[192]) { foreach ($group in $AppGroups[192].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[193]) { foreach ($group in $AppGroups[193].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[194]) { foreach ($group in $AppGroups[194].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[195]) { foreach ($group in $AppGroups[195].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[196]) { foreach ($group in $AppGroups[196].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[197]) { foreach ($group in $AppGroups[197].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[198]) { foreach ($group in $AppGroups[198].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[199]) { foreach ($group in $AppGroups[199].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[200]) { foreach ($group in $AppGroups[200].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[201]) { foreach ($group in $AppGroups[201].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[202]) { foreach ($group in $AppGroups[202].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[203]) { foreach ($group in $AppGroups[203].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[204]) { foreach ($group in $AppGroups[204].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[205]) { foreach ($group in $AppGroups[205].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[206]) { foreach ($group in $AppGroups[206].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[207]) { foreach ($group in $AppGroups[207].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[208]) { foreach ($group in $AppGroups[208].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[209]) { foreach ($group in $AppGroups[209].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[210]) { foreach ($group in $AppGroups[210].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[211]) { foreach ($group in $AppGroups[211].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[212]) { foreach ($group in $AppGroups[212].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[213]) { foreach ($group in $AppGroups[213].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[214]) { foreach ($group in $AppGroups[214].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[215]) { foreach ($group in $AppGroups[215].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[216]) { foreach ($group in $AppGroups[216].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[217]) { foreach ($group in $AppGroups[217].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[218]) { foreach ($group in $AppGroups[218].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[219]) { foreach ($group in $AppGroups[219].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[220]) { foreach ($group in $AppGroups[220].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[221]) { foreach ($group in $AppGroups[221].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[222]) { foreach ($group in $AppGroups[222].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[223]) { foreach ($group in $AppGroups[223].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[224]) { foreach ($group in $AppGroups[224].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[225]) { foreach ($group in $AppGroups[225].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[226]) { foreach ($group in $AppGroups[226].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[227]) { foreach ($group in $AppGroups[227].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[228]) { foreach ($group in $AppGroups[228].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[229]) { foreach ($group in $AppGroups[229].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[230]) { foreach ($group in $AppGroups[230].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[231]) { foreach ($group in $AppGroups[231].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[232]) { foreach ($group in $AppGroups[232].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[233]) { foreach ($group in $AppGroups[233].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[234]) { foreach ($group in $AppGroups[234].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[235]) { foreach ($group in $AppGroups[235].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[236]) { foreach ($group in $AppGroups[236].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[237]) { foreach ($group in $AppGroups[237].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[238]) { foreach ($group in $AppGroups[238].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[239]) { foreach ($group in $AppGroups[239].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[240]) { foreach ($group in $AppGroups[240].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[241]) { foreach ($group in $AppGroups[241].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[242]) { foreach ($group in $AppGroups[242].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[243]) { foreach ($group in $AppGroups[243].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[244]) { foreach ($group in $AppGroups[244].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[245]) { foreach ($group in $AppGroups[245].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[246]) { foreach ($group in $AppGroups[246].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[247]) { foreach ($group in $AppGroups[247].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[248]) { foreach ($group in $AppGroups[248].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[249]) { foreach ($group in $AppGroups[249].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[250]) { foreach ($group in $AppGroups[250].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[251]) { foreach ($group in $AppGroups[251].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[252]) { foreach ($group in $AppGroups[252].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[253]) { foreach ($group in $AppGroups[253].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[254]) { foreach ($group in $AppGroups[254].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[255]) { foreach ($group in $AppGroups[255].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[256]) { foreach ($group in $AppGroups[256].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[257]) { foreach ($group in $AppGroups[257].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[258]) { foreach ($group in $AppGroups[258].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[259]) { foreach ($group in $AppGroups[259].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[260]) { foreach ($group in $AppGroups[260].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[261]) { foreach ($group in $AppGroups[261].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[262]) { foreach ($group in $AppGroups[262].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[263]) { foreach ($group in $AppGroups[263].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[264]) { foreach ($group in $AppGroups[264].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[265]) { foreach ($group in $AppGroups[265].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[266]) { foreach ($group in $AppGroups[266].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[267]) { foreach ($group in $AppGroups[267].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[268]) { foreach ($group in $AppGroups[268].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[269]) { foreach ($group in $AppGroups[269].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[270]) { foreach ($group in $AppGroups[270].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[271]) { foreach ($group in $AppGroups[271].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[272]) { foreach ($group in $AppGroups[272].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[273]) { foreach ($group in $AppGroups[273].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[274]) { foreach ($group in $AppGroups[274].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[275]) { foreach ($group in $AppGroups[275].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[276]) { foreach ($group in $AppGroups[276].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[277]) { foreach ($group in $AppGroups[277].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[278]) { foreach ($group in $AppGroups[278].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[279]) { foreach ($group in $AppGroups[279].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[280]) { foreach ($group in $AppGroups[280].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[281]) { foreach ($group in $AppGroups[281].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[282]) { foreach ($group in $AppGroups[282].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[283]) { foreach ($group in $AppGroups[283].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[284]) { foreach ($group in $AppGroups[284].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[285]) { foreach ($group in $AppGroups[285].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[286]) { foreach ($group in $AppGroups[286].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[287]) { foreach ($group in $AppGroups[287].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[288]) { foreach ($group in $AppGroups[288].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[289]) { foreach ($group in $AppGroups[289].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[290]) { foreach ($group in $AppGroups[290].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[291]) { foreach ($group in $AppGroups[291].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[292]) { foreach ($group in $AppGroups[292].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[293]) { foreach ($group in $AppGroups[293].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[294]) { foreach ($group in $AppGroups[294].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[295]) { foreach ($group in $AppGroups[295].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[296]) { foreach ($group in $AppGroups[296].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[297]) { foreach ($group in $AppGroups[297].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[298]) { foreach ($group in $AppGroups[298].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[299]) { foreach ($group in $AppGroups[299].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[300]) { foreach ($group in $AppGroups[300].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[301]) { foreach ($group in $AppGroups[301].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[302]) { foreach ($group in $AppGroups[302].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[303]) { foreach ($group in $AppGroups[303].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[304]) { foreach ($group in $AppGroups[304].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[305]) { foreach ($group in $AppGroups[305].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[306]) { foreach ($group in $AppGroups[306].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[307]) { foreach ($group in $AppGroups[307].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[308]) { foreach ($group in $AppGroups[308].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[309]) { foreach ($group in $AppGroups[309].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[310]) { foreach ($group in $AppGroups[310].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[311]) { foreach ($group in $AppGroups[311].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[312]) { foreach ($group in $AppGroups[312].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[313]) { foreach ($group in $AppGroups[313].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[314]) { foreach ($group in $AppGroups[314].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[315]) { foreach ($group in $AppGroups[315].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[316]) { foreach ($group in $AppGroups[316].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[317]) { foreach ($group in $AppGroups[317].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[318]) { foreach ($group in $AppGroups[318].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[319]) { foreach ($group in $AppGroups[319].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[320]) { foreach ($group in $AppGroups[320].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[321]) { foreach ($group in $AppGroups[321].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[322]) { foreach ($group in $AppGroups[322].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[323]) { foreach ($group in $AppGroups[323].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[324]) { foreach ($group in $AppGroups[324].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[325]) { foreach ($group in $AppGroups[325].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[326]) { foreach ($group in $AppGroups[326].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[327]) { foreach ($group in $AppGroups[327].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[328]) { foreach ($group in $AppGroups[328].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[329]) { foreach ($group in $AppGroups[329].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[330]) { foreach ($group in $AppGroups[330].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[331]) { foreach ($group in $AppGroups[331].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[332]) { foreach ($group in $AppGroups[332].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[333]) { foreach ($group in $AppGroups[333].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[334]) { foreach ($group in $AppGroups[334].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[335]) { foreach ($group in $AppGroups[335].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[336]) { foreach ($group in $AppGroups[336].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[337]) { foreach ($group in $AppGroups[337].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[338]) { foreach ($group in $AppGroups[338].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[339]) { foreach ($group in $AppGroups[339].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[340]) { foreach ($group in $AppGroups[340].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[341]) { foreach ($group in $AppGroups[341].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[342]) { foreach ($group in $AppGroups[342].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[343]) { foreach ($group in $AppGroups[343].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[344]) { foreach ($group in $AppGroups[344].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[345]) { foreach ($group in $AppGroups[345].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[346]) { foreach ($group in $AppGroups[346].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[347]) { foreach ($group in $AppGroups[347].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[348]) { foreach ($group in $AppGroups[348].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[349]) { foreach ($group in $AppGroups[349].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[350]) { foreach ($group in $AppGroups[350].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[351]) { foreach ($group in $AppGroups[351].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[352]) { foreach ($group in $AppGroups[352].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[353]) { foreach ($group in $AppGroups[353].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[354]) { foreach ($group in $AppGroups[354].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[355]) { foreach ($group in $AppGroups[355].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[356]) { foreach ($group in $AppGroups[356].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[357]) { foreach ($group in $AppGroups[357].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[358]) { foreach ($group in $AppGroups[358].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[359]) { foreach ($group in $AppGroups[359].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[360]) { foreach ($group in $AppGroups[360].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[361]) { foreach ($group in $AppGroups[361].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[362]) { foreach ($group in $AppGroups[362].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[363]) { foreach ($group in $AppGroups[363].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[364]) { foreach ($group in $AppGroups[364].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[365]) { foreach ($group in $AppGroups[365].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[366]) { foreach ($group in $AppGroups[366].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[367]) { foreach ($group in $AppGroups[367].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[368]) { foreach ($group in $AppGroups[368].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[369]) { foreach ($group in $AppGroups[369].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[370]) { foreach ($group in $AppGroups[370].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[371]) { foreach ($group in $AppGroups[371].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[372]) { foreach ($group in $AppGroups[372].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[373]) { foreach ($group in $AppGroups[373].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[374]) { foreach ($group in $AppGroups[374].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[375]) { foreach ($group in $AppGroups[375].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[376]) { foreach ($group in $AppGroups[376].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[377]) { foreach ($group in $AppGroups[377].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[378]) { foreach ($group in $AppGroups[378].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[379]) { foreach ($group in $AppGroups[379].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[380]) { foreach ($group in $AppGroups[380].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[381]) { foreach ($group in $AppGroups[381].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[382]) { foreach ($group in $AppGroups[382].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[383]) { foreach ($group in $AppGroups[383].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[384]) { foreach ($group in $AppGroups[384].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[385]) { foreach ($group in $AppGroups[385].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[386]) { foreach ($group in $AppGroups[386].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[387]) { foreach ($group in $AppGroups[387].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[388]) { foreach ($group in $AppGroups[388].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[389]) { foreach ($group in $AppGroups[389].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[390]) { foreach ($group in $AppGroups[390].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[391]) { foreach ($group in $AppGroups[391].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[392]) { foreach ($group in $AppGroups[392].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[393]) { foreach ($group in $AppGroups[393].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[394]) { foreach ($group in $AppGroups[394].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[395]) { foreach ($group in $AppGroups[395].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[396]) { foreach ($group in $AppGroups[396].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[397]) { foreach ($group in $AppGroups[397].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[398]) { foreach ($group in $AppGroups[398].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[399]) { foreach ($group in $AppGroups[399].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[400]) { foreach ($group in $AppGroups[400].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[401]) { foreach ($group in $AppGroups[401].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[402]) { foreach ($group in $AppGroups[402].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[403]) { foreach ($group in $AppGroups[403].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[404]) { foreach ($group in $AppGroups[404].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[405]) { foreach ($group in $AppGroups[405].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[406]) { foreach ($group in $AppGroups[406].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[407]) { foreach ($group in $AppGroups[407].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[408]) { foreach ($group in $AppGroups[408].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[409]) { foreach ($group in $AppGroups[409].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[410]) { foreach ($group in $AppGroups[410].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[411]) { foreach ($group in $AppGroups[411].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[412]) { foreach ($group in $AppGroups[412].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[413]) { foreach ($group in $AppGroups[413].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[414]) { foreach ($group in $AppGroups[414].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[415]) { foreach ($group in $AppGroups[415].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[416]) { foreach ($group in $AppGroups[416].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[417]) { foreach ($group in $AppGroups[417].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[418]) { foreach ($group in $AppGroups[418].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[419]) { foreach ($group in $AppGroups[419].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[420]) { foreach ($group in $AppGroups[420].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[421]) { foreach ($group in $AppGroups[421].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[422]) { foreach ($group in $AppGroups[422].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[423]) { foreach ($group in $AppGroups[423].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[424]) { foreach ($group in $AppGroups[424].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[425]) { foreach ($group in $AppGroups[425].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[426]) { foreach ($group in $AppGroups[426].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[427]) { foreach ($group in $AppGroups[427].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[428]) { foreach ($group in $AppGroups[428].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[429]) { foreach ($group in $AppGroups[429].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[430]) { foreach ($group in $AppGroups[430].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[431]) { foreach ($group in $AppGroups[431].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[432]) { foreach ($group in $AppGroups[432].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[433]) { foreach ($group in $AppGroups[433].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[434]) { foreach ($group in $AppGroups[434].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[435]) { foreach ($group in $AppGroups[435].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[436]) { foreach ($group in $AppGroups[436].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[437]) { foreach ($group in $AppGroups[437].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[438]) { foreach ($group in $AppGroups[438].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[439]) { foreach ($group in $AppGroups[439].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[440]) { foreach ($group in $AppGroups[440].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[441]) { foreach ($group in $AppGroups[441].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[442]) { foreach ($group in $AppGroups[442].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[443]) { foreach ($group in $AppGroups[443].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[444]) { foreach ($group in $AppGroups[444].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[445]) { foreach ($group in $AppGroups[445].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[446]) { foreach ($group in $AppGroups[446].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[447]) { foreach ($group in $AppGroups[447].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[448]) { foreach ($group in $AppGroups[448].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[449]) { foreach ($group in $AppGroups[449].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[450]) { foreach ($group in $AppGroups[450].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[451]) { foreach ($group in $AppGroups[451].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[452]) { foreach ($group in $AppGroups[452].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[453]) { foreach ($group in $AppGroups[453].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[454]) { foreach ($group in $AppGroups[454].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[455]) { foreach ($group in $AppGroups[455].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[456]) { foreach ($group in $AppGroups[456].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[457]) { foreach ($group in $AppGroups[457].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[458]) { foreach ($group in $AppGroups[458].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[459]) { foreach ($group in $AppGroups[459].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[460]) { foreach ($group in $AppGroups[460].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[461]) { foreach ($group in $AppGroups[461].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[462]) { foreach ($group in $AppGroups[462].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[463]) { foreach ($group in $AppGroups[463].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[464]) { foreach ($group in $AppGroups[464].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[465]) { foreach ($group in $AppGroups[465].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[466]) { foreach ($group in $AppGroups[466].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[467]) { foreach ($group in $AppGroups[467].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[468]) { foreach ($group in $AppGroups[468].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[469]) { foreach ($group in $AppGroups[469].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[470]) { foreach ($group in $AppGroups[470].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[471]) { foreach ($group in $AppGroups[471].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[472]) { foreach ($group in $AppGroups[472].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[473]) { foreach ($group in $AppGroups[473].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[474]) { foreach ($group in $AppGroups[474].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[475]) { foreach ($group in $AppGroups[475].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[476]) { foreach ($group in $AppGroups[476].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[477]) { foreach ($group in $AppGroups[477].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[478]) { foreach ($group in $AppGroups[478].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[479]) { foreach ($group in $AppGroups[479].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[480]) { foreach ($group in $AppGroups[480].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[481]) { foreach ($group in $AppGroups[481].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[482]) { foreach ($group in $AppGroups[482].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[483]) { foreach ($group in $AppGroups[483].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[484]) { foreach ($group in $AppGroups[484].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[485]) { foreach ($group in $AppGroups[485].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[486]) { foreach ($group in $AppGroups[486].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[487]) { foreach ($group in $AppGroups[487].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[488]) { foreach ($group in $AppGroups[488].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[489]) { foreach ($group in $AppGroups[489].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[490]) { foreach ($group in $AppGroups[490].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[491]) { foreach ($group in $AppGroups[491].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[492]) { foreach ($group in $AppGroups[492].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[493]) { foreach ($group in $AppGroups[493].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[494]) { foreach ($group in $AppGroups[494].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[495]) { foreach ($group in $AppGroups[495].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[496]) { foreach ($group in $AppGroups[496].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[497]) { foreach ($group in $AppGroups[497].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[498]) { foreach ($group in $AppGroups[498].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[499]) { foreach ($group in $AppGroups[499].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[500]) { foreach ($group in $AppGroups[500].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[501]) { foreach ($group in $AppGroups[501].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[502]) { foreach ($group in $AppGroups[502].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[503]) { foreach ($group in $AppGroups[503].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[504]) { foreach ($group in $AppGroups[504].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[505]) { foreach ($group in $AppGroups[505].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[506]) { foreach ($group in $AppGroups[506].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[507]) { foreach ($group in $AppGroups[507].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[508]) { foreach ($group in $AppGroups[508].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[509]) { foreach ($group in $AppGroups[509].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[510]) { foreach ($group in $AppGroups[510].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[511]) { foreach ($group in $AppGroups[511].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[512]) { foreach ($group in $AppGroups[512].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[513]) { foreach ($group in $AppGroups[513].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[514]) { foreach ($group in $AppGroups[514].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[515]) { foreach ($group in $AppGroups[515].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[516]) { foreach ($group in $AppGroups[516].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[517]) { foreach ($group in $AppGroups[517].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[518]) { foreach ($group in $AppGroups[518].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[519]) { foreach ($group in $AppGroups[519].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[520]) { foreach ($group in $AppGroups[520].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[521]) { foreach ($group in $AppGroups[521].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[522]) { foreach ($group in $AppGroups[522].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[523]) { foreach ($group in $AppGroups[523].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[524]) { foreach ($group in $AppGroups[524].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[525]) { foreach ($group in $AppGroups[525].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[526]) { foreach ($group in $AppGroups[526].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[527]) { foreach ($group in $AppGroups[527].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[528]) { foreach ($group in $AppGroups[528].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[529]) { foreach ($group in $AppGroups[529].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[530]) { foreach ($group in $AppGroups[530].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[531]) { foreach ($group in $AppGroups[531].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[532]) { foreach ($group in $AppGroups[532].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[533]) { foreach ($group in $AppGroups[533].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[534]) { foreach ($group in $AppGroups[534].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[535]) { foreach ($group in $AppGroups[535].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[536]) { foreach ($group in $AppGroups[536].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[537]) { foreach ($group in $AppGroups[537].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[538]) { foreach ($group in $AppGroups[538].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[539]) { foreach ($group in $AppGroups[539].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[540]) { foreach ($group in $AppGroups[540].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[541]) { foreach ($group in $AppGroups[541].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[542]) { foreach ($group in $AppGroups[542].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[543]) { foreach ($group in $AppGroups[543].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[544]) { foreach ($group in $AppGroups[544].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[545]) { foreach ($group in $AppGroups[545].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[546]) { foreach ($group in $AppGroups[546].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[547]) { foreach ($group in $AppGroups[547].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[548]) { foreach ($group in $AppGroups[548].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[549]) { foreach ($group in $AppGroups[549].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[550]) { foreach ($group in $AppGroups[550].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[551]) { foreach ($group in $AppGroups[551].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[552]) { foreach ($group in $AppGroups[552].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[553]) { foreach ($group in $AppGroups[553].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[554]) { foreach ($group in $AppGroups[554].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[555]) { foreach ($group in $AppGroups[555].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[556]) { foreach ($group in $AppGroups[556].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[557]) { foreach ($group in $AppGroups[557].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[558]) { foreach ($group in $AppGroups[558].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[559]) { foreach ($group in $AppGroups[559].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[560]) { foreach ($group in $AppGroups[560].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[561]) { foreach ($group in $AppGroups[561].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[562]) { foreach ($group in $AppGroups[562].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[563]) { foreach ($group in $AppGroups[563].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[564]) { foreach ($group in $AppGroups[564].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[565]) { foreach ($group in $AppGroups[565].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[566]) { foreach ($group in $AppGroups[566].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[567]) { foreach ($group in $AppGroups[567].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[568]) { foreach ($group in $AppGroups[568].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[569]) { foreach ($group in $AppGroups[569].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[570]) { foreach ($group in $AppGroups[570].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[571]) { foreach ($group in $AppGroups[571].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[572]) { foreach ($group in $AppGroups[572].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[573]) { foreach ($group in $AppGroups[573].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[574]) { foreach ($group in $AppGroups[574].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[575]) { foreach ($group in $AppGroups[575].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[576]) { foreach ($group in $AppGroups[576].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[577]) { foreach ($group in $AppGroups[577].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[578]) { foreach ($group in $AppGroups[578].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[579]) { foreach ($group in $AppGroups[579].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[580]) { foreach ($group in $AppGroups[580].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[581]) { foreach ($group in $AppGroups[581].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[582]) { foreach ($group in $AppGroups[582].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[583]) { foreach ($group in $AppGroups[583].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[584]) { foreach ($group in $AppGroups[584].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[585]) { foreach ($group in $AppGroups[585].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[586]) { foreach ($group in $AppGroups[586].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[587]) { foreach ($group in $AppGroups[587].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[588]) { foreach ($group in $AppGroups[588].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[589]) { foreach ($group in $AppGroups[589].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[590]) { foreach ($group in $AppGroups[590].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[591]) { foreach ($group in $AppGroups[591].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[592]) { foreach ($group in $AppGroups[592].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[593]) { foreach ($group in $AppGroups[593].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[594]) { foreach ($group in $AppGroups[594].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[595]) { foreach ($group in $AppGroups[595].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[596]) { foreach ($group in $AppGroups[596].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[597]) { foreach ($group in $AppGroups[597].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[598]) { foreach ($group in $AppGroups[598].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[599]) { foreach ($group in $AppGroups[599].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[600]) { foreach ($group in $AppGroups[600].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[601]) { foreach ($group in $AppGroups[601].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[602]) { foreach ($group in $AppGroups[602].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[603]) { foreach ($group in $AppGroups[603].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[604]) { foreach ($group in $AppGroups[604].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[605]) { foreach ($group in $AppGroups[605].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[606]) { foreach ($group in $AppGroups[606].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[607]) { foreach ($group in $AppGroups[607].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[608]) { foreach ($group in $AppGroups[608].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[609]) { foreach ($group in $AppGroups[609].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[610]) { foreach ($group in $AppGroups[610].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[611]) { foreach ($group in $AppGroups[611].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[612]) { foreach ($group in $AppGroups[612].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[613]) { foreach ($group in $AppGroups[613].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[614]) { foreach ($group in $AppGroups[614].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[615]) { foreach ($group in $AppGroups[615].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[616]) { foreach ($group in $AppGroups[616].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[617]) { foreach ($group in $AppGroups[617].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[618]) { foreach ($group in $AppGroups[618].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[619]) { foreach ($group in $AppGroups[619].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[620]) { foreach ($group in $AppGroups[620].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[621]) { foreach ($group in $AppGroups[621].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[622]) { foreach ($group in $AppGroups[622].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[623]) { foreach ($group in $AppGroups[623].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[624]) { foreach ($group in $AppGroups[624].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[625]) { foreach ($group in $AppGroups[625].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[626]) { foreach ($group in $AppGroups[626].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[627]) { foreach ($group in $AppGroups[627].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[628]) { foreach ($group in $AppGroups[628].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[629]) { foreach ($group in $AppGroups[629].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[630]) { foreach ($group in $AppGroups[630].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[631]) { foreach ($group in $AppGroups[631].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[632]) { foreach ($group in $AppGroups[632].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[633]) { foreach ($group in $AppGroups[633].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[634]) { foreach ($group in $AppGroups[634].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[635]) { foreach ($group in $AppGroups[635].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[636]) { foreach ($group in $AppGroups[636].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[637]) { foreach ($group in $AppGroups[637].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[638]) { foreach ($group in $AppGroups[638].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[639]) { foreach ($group in $AppGroups[639].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[640]) { foreach ($group in $AppGroups[640].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[641]) { foreach ($group in $AppGroups[641].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[642]) { foreach ($group in $AppGroups[642].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[643]) { foreach ($group in $AppGroups[643].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[644]) { foreach ($group in $AppGroups[644].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[645]) { foreach ($group in $AppGroups[645].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[646]) { foreach ($group in $AppGroups[646].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[647]) { foreach ($group in $AppGroups[647].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[648]) { foreach ($group in $AppGroups[648].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[649]) { foreach ($group in $AppGroups[649].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[650]) { foreach ($group in $AppGroups[650].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[651]) { foreach ($group in $AppGroups[651].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[652]) { foreach ($group in $AppGroups[652].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[653]) { foreach ($group in $AppGroups[653].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[654]) { foreach ($group in $AppGroups[654].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[655]) { foreach ($group in $AppGroups[655].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[656]) { foreach ($group in $AppGroups[656].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[657]) { foreach ($group in $AppGroups[657].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[658]) { foreach ($group in $AppGroups[658].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[659]) { foreach ($group in $AppGroups[659].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[660]) { foreach ($group in $AppGroups[660].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[661]) { foreach ($group in $AppGroups[661].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[662]) { foreach ($group in $AppGroups[662].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[663]) { foreach ($group in $AppGroups[663].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[664]) { foreach ($group in $AppGroups[664].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[665]) { foreach ($group in $AppGroups[665].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[666]) { foreach ($group in $AppGroups[666].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[667]) { foreach ($group in $AppGroups[667].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[668]) { foreach ($group in $AppGroups[668].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[669]) { foreach ($group in $AppGroups[669].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[670]) { foreach ($group in $AppGroups[670].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[671]) { foreach ($group in $AppGroups[671].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[672]) { foreach ($group in $AppGroups[672].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[673]) { foreach ($group in $AppGroups[673].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[674]) { foreach ($group in $AppGroups[674].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[675]) { foreach ($group in $AppGroups[675].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[676]) { foreach ($group in $AppGroups[676].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[677]) { foreach ($group in $AppGroups[677].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[678]) { foreach ($group in $AppGroups[678].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[679]) { foreach ($group in $AppGroups[679].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[680]) { foreach ($group in $AppGroups[680].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[681]) { foreach ($group in $AppGroups[681].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[682]) { foreach ($group in $AppGroups[682].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[683]) { foreach ($group in $AppGroups[683].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[684]) { foreach ($group in $AppGroups[684].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[685]) { foreach ($group in $AppGroups[685].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[686]) { foreach ($group in $AppGroups[686].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[687]) { foreach ($group in $AppGroups[687].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[688]) { foreach ($group in $AppGroups[688].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[689]) { foreach ($group in $AppGroups[689].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[690]) { foreach ($group in $AppGroups[690].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[691]) { foreach ($group in $AppGroups[691].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[692]) { foreach ($group in $AppGroups[692].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[693]) { foreach ($group in $AppGroups[693].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[694]) { foreach ($group in $AppGroups[694].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[695]) { foreach ($group in $AppGroups[695].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[696]) { foreach ($group in $AppGroups[696].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[697]) { foreach ($group in $AppGroups[697].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[698]) { foreach ($group in $AppGroups[698].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[699]) { foreach ($group in $AppGroups[699].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[700]) { foreach ($group in $AppGroups[700].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[701]) { foreach ($group in $AppGroups[701].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[702]) { foreach ($group in $AppGroups[702].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[703]) { foreach ($group in $AppGroups[703].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[704]) { foreach ($group in $AppGroups[704].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[705]) { foreach ($group in $AppGroups[705].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[706]) { foreach ($group in $AppGroups[706].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[707]) { foreach ($group in $AppGroups[707].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[708]) { foreach ($group in $AppGroups[708].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[709]) { foreach ($group in $AppGroups[709].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[710]) { foreach ($group in $AppGroups[710].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[711]) { foreach ($group in $AppGroups[711].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[712]) { foreach ($group in $AppGroups[712].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[713]) { foreach ($group in $AppGroups[713].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[714]) { foreach ($group in $AppGroups[714].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[715]) { foreach ($group in $AppGroups[715].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[716]) { foreach ($group in $AppGroups[716].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[717]) { foreach ($group in $AppGroups[717].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[718]) { foreach ($group in $AppGroups[718].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[719]) { foreach ($group in $AppGroups[719].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[720]) { foreach ($group in $AppGroups[720].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[721]) { foreach ($group in $AppGroups[721].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[722]) { foreach ($group in $AppGroups[722].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[723]) { foreach ($group in $AppGroups[723].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[724]) { foreach ($group in $AppGroups[724].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[725]) { foreach ($group in $AppGroups[725].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[726]) { foreach ($group in $AppGroups[726].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[727]) { foreach ($group in $AppGroups[727].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[728]) { foreach ($group in $AppGroups[728].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[729]) { foreach ($group in $AppGroups[729].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[730]) { foreach ($group in $AppGroups[730].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[731]) { foreach ($group in $AppGroups[731].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[732]) { foreach ($group in $AppGroups[732].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[733]) { foreach ($group in $AppGroups[733].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[734]) { foreach ($group in $AppGroups[734].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[735]) { foreach ($group in $AppGroups[735].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[736]) { foreach ($group in $AppGroups[736].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[737]) { foreach ($group in $AppGroups[737].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[738]) { foreach ($group in $AppGroups[738].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[739]) { foreach ($group in $AppGroups[739].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[740]) { foreach ($group in $AppGroups[740].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[741]) { foreach ($group in $AppGroups[741].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[742]) { foreach ($group in $AppGroups[742].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[743]) { foreach ($group in $AppGroups[743].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[744]) { foreach ($group in $AppGroups[744].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[745]) { foreach ($group in $AppGroups[745].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[746]) { foreach ($group in $AppGroups[746].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[747]) { foreach ($group in $AppGroups[747].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[748]) { foreach ($group in $AppGroups[748].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[749]) { foreach ($group in $AppGroups[749].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[750]) { foreach ($group in $AppGroups[750].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[751]) { foreach ($group in $AppGroups[751].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[752]) { foreach ($group in $AppGroups[752].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[753]) { foreach ($group in $AppGroups[753].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[754]) { foreach ($group in $AppGroups[754].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[755]) { foreach ($group in $AppGroups[755].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[756]) { foreach ($group in $AppGroups[756].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[757]) { foreach ($group in $AppGroups[757].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[758]) { foreach ($group in $AppGroups[758].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[759]) { foreach ($group in $AppGroups[759].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[760]) { foreach ($group in $AppGroups[760].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[761]) { foreach ($group in $AppGroups[761].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[762]) { foreach ($group in $AppGroups[762].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[763]) { foreach ($group in $AppGroups[763].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[764]) { foreach ($group in $AppGroups[764].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[765]) { foreach ($group in $AppGroups[765].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[766]) { foreach ($group in $AppGroups[766].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[767]) { foreach ($group in $AppGroups[767].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[768]) { foreach ($group in $AppGroups[768].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[769]) { foreach ($group in $AppGroups[769].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[770]) { foreach ($group in $AppGroups[770].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[771]) { foreach ($group in $AppGroups[771].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[772]) { foreach ($group in $AppGroups[772].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[773]) { foreach ($group in $AppGroups[773].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[774]) { foreach ($group in $AppGroups[774].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[775]) { foreach ($group in $AppGroups[775].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[776]) { foreach ($group in $AppGroups[776].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[777]) { foreach ($group in $AppGroups[777].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[778]) { foreach ($group in $AppGroups[778].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[779]) { foreach ($group in $AppGroups[779].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[780]) { foreach ($group in $AppGroups[780].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[781]) { foreach ($group in $AppGroups[781].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[782]) { foreach ($group in $AppGroups[782].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[783]) { foreach ($group in $AppGroups[783].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[784]) { foreach ($group in $AppGroups[784].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[785]) { foreach ($group in $AppGroups[785].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[786]) { foreach ($group in $AppGroups[786].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[787]) { foreach ($group in $AppGroups[787].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[788]) { foreach ($group in $AppGroups[788].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[789]) { foreach ($group in $AppGroups[789].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[790]) { foreach ($group in $AppGroups[790].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[791]) { foreach ($group in $AppGroups[791].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[792]) { foreach ($group in $AppGroups[792].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[793]) { foreach ($group in $AppGroups[793].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[794]) { foreach ($group in $AppGroups[794].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[795]) { foreach ($group in $AppGroups[795].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[796]) { foreach ($group in $AppGroups[796].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[797]) { foreach ($group in $AppGroups[797].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[798]) { foreach ($group in $AppGroups[798].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[799]) { foreach ($group in $AppGroups[799].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[800]) { foreach ($group in $AppGroups[800].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[801]) { foreach ($group in $AppGroups[801].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[802]) { foreach ($group in $AppGroups[802].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[803]) { foreach ($group in $AppGroups[803].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[804]) { foreach ($group in $AppGroups[804].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[805]) { foreach ($group in $AppGroups[805].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[806]) { foreach ($group in $AppGroups[806].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[807]) { foreach ($group in $AppGroups[807].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[808]) { foreach ($group in $AppGroups[808].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[809]) { foreach ($group in $AppGroups[809].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[810]) { foreach ($group in $AppGroups[810].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[811]) { foreach ($group in $AppGroups[811].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[812]) { foreach ($group in $AppGroups[812].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[813]) { foreach ($group in $AppGroups[813].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[814]) { foreach ($group in $AppGroups[814].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[815]) { foreach ($group in $AppGroups[815].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[816]) { foreach ($group in $AppGroups[816].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[817]) { foreach ($group in $AppGroups[817].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[818]) { foreach ($group in $AppGroups[818].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[819]) { foreach ($group in $AppGroups[819].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[820]) { foreach ($group in $AppGroups[820].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[821]) { foreach ($group in $AppGroups[821].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[822]) { foreach ($group in $AppGroups[822].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[823]) { foreach ($group in $AppGroups[823].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[824]) { foreach ($group in $AppGroups[824].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[825]) { foreach ($group in $AppGroups[825].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[826]) { foreach ($group in $AppGroups[826].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[827]) { foreach ($group in $AppGroups[827].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[828]) { foreach ($group in $AppGroups[828].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[829]) { foreach ($group in $AppGroups[829].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[830]) { foreach ($group in $AppGroups[830].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[831]) { foreach ($group in $AppGroups[831].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[832]) { foreach ($group in $AppGroups[832].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[833]) { foreach ($group in $AppGroups[833].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[834]) { foreach ($group in $AppGroups[834].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[835]) { foreach ($group in $AppGroups[835].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[836]) { foreach ($group in $AppGroups[836].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[837]) { foreach ($group in $AppGroups[837].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[838]) { foreach ($group in $AppGroups[838].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[839]) { foreach ($group in $AppGroups[839].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[840]) { foreach ($group in $AppGroups[840].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[841]) { foreach ($group in $AppGroups[841].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[842]) { foreach ($group in $AppGroups[842].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[843]) { foreach ($group in $AppGroups[843].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[844]) { foreach ($group in $AppGroups[844].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[845]) { foreach ($group in $AppGroups[845].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[846]) { foreach ($group in $AppGroups[846].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[847]) { foreach ($group in $AppGroups[847].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[848]) { foreach ($group in $AppGroups[848].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[849]) { foreach ($group in $AppGroups[849].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[850]) { foreach ($group in $AppGroups[850].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[851]) { foreach ($group in $AppGroups[851].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[852]) { foreach ($group in $AppGroups[852].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[853]) { foreach ($group in $AppGroups[853].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[854]) { foreach ($group in $AppGroups[854].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[855]) { foreach ($group in $AppGroups[855].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[856]) { foreach ($group in $AppGroups[856].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[857]) { foreach ($group in $AppGroups[857].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[858]) { foreach ($group in $AppGroups[858].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[859]) { foreach ($group in $AppGroups[859].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[860]) { foreach ($group in $AppGroups[860].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[861]) { foreach ($group in $AppGroups[861].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[862]) { foreach ($group in $AppGroups[862].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[863]) { foreach ($group in $AppGroups[863].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[864]) { foreach ($group in $AppGroups[864].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[865]) { foreach ($group in $AppGroups[865].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[866]) { foreach ($group in $AppGroups[866].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[867]) { foreach ($group in $AppGroups[867].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[868]) { foreach ($group in $AppGroups[868].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[869]) { foreach ($group in $AppGroups[869].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[870]) { foreach ($group in $AppGroups[870].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[871]) { foreach ($group in $AppGroups[871].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[872]) { foreach ($group in $AppGroups[872].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[873]) { foreach ($group in $AppGroups[873].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[874]) { foreach ($group in $AppGroups[874].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[875]) { foreach ($group in $AppGroups[875].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[876]) { foreach ($group in $AppGroups[876].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[877]) { foreach ($group in $AppGroups[877].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[878]) { foreach ($group in $AppGroups[878].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[879]) { foreach ($group in $AppGroups[879].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[880]) { foreach ($group in $AppGroups[880].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[881]) { foreach ($group in $AppGroups[881].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[882]) { foreach ($group in $AppGroups[882].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[883]) { foreach ($group in $AppGroups[883].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[884]) { foreach ($group in $AppGroups[884].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[885]) { foreach ($group in $AppGroups[885].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[886]) { foreach ($group in $AppGroups[886].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[887]) { foreach ($group in $AppGroups[887].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[888]) { foreach ($group in $AppGroups[888].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[889]) { foreach ($group in $AppGroups[889].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[890]) { foreach ($group in $AppGroups[890].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[891]) { foreach ($group in $AppGroups[891].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[892]) { foreach ($group in $AppGroups[892].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[893]) { foreach ($group in $AppGroups[893].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[894]) { foreach ($group in $AppGroups[894].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[895]) { foreach ($group in $AppGroups[895].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[896]) { foreach ($group in $AppGroups[896].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[897]) { foreach ($group in $AppGroups[897].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[898]) { foreach ($group in $AppGroups[898].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[899]) { foreach ($group in $AppGroups[899].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[900]) { foreach ($group in $AppGroups[900].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[901]) { foreach ($group in $AppGroups[901].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[902]) { foreach ($group in $AppGroups[902].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[903]) { foreach ($group in $AppGroups[903].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[904]) { foreach ($group in $AppGroups[904].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[905]) { foreach ($group in $AppGroups[905].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[906]) { foreach ($group in $AppGroups[906].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[907]) { foreach ($group in $AppGroups[907].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[908]) { foreach ($group in $AppGroups[908].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[909]) { foreach ($group in $AppGroups[909].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[910]) { foreach ($group in $AppGroups[910].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[911]) { foreach ($group in $AppGroups[911].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[912]) { foreach ($group in $AppGroups[912].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[913]) { foreach ($group in $AppGroups[913].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[914]) { foreach ($group in $AppGroups[914].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[915]) { foreach ($group in $AppGroups[915].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[916]) { foreach ($group in $AppGroups[916].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[917]) { foreach ($group in $AppGroups[917].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[918]) { foreach ($group in $AppGroups[918].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[919]) { foreach ($group in $AppGroups[919].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[920]) { foreach ($group in $AppGroups[920].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[921]) { foreach ($group in $AppGroups[921].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[922]) { foreach ($group in $AppGroups[922].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[923]) { foreach ($group in $AppGroups[923].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[924]) { foreach ($group in $AppGroups[924].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[925]) { foreach ($group in $AppGroups[925].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[926]) { foreach ($group in $AppGroups[926].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[927]) { foreach ($group in $AppGroups[927].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[928]) { foreach ($group in $AppGroups[928].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[929]) { foreach ($group in $AppGroups[929].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[930]) { foreach ($group in $AppGroups[930].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[931]) { foreach ($group in $AppGroups[931].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[932]) { foreach ($group in $AppGroups[932].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[933]) { foreach ($group in $AppGroups[933].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[934]) { foreach ($group in $AppGroups[934].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[935]) { foreach ($group in $AppGroups[935].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[936]) { foreach ($group in $AppGroups[936].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[937]) { foreach ($group in $AppGroups[937].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[938]) { foreach ($group in $AppGroups[938].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[939]) { foreach ($group in $AppGroups[939].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[940]) { foreach ($group in $AppGroups[940].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[941]) { foreach ($group in $AppGroups[941].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[942]) { foreach ($group in $AppGroups[942].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[943]) { foreach ($group in $AppGroups[943].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[944]) { foreach ($group in $AppGroups[944].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[945]) { foreach ($group in $AppGroups[945].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[946]) { foreach ($group in $AppGroups[946].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[947]) { foreach ($group in $AppGroups[947].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[948]) { foreach ($group in $AppGroups[948].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[949]) { foreach ($group in $AppGroups[949].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[950]) { foreach ($group in $AppGroups[950].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[951]) { foreach ($group in $AppGroups[951].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[952]) { foreach ($group in $AppGroups[952].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[953]) { foreach ($group in $AppGroups[953].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[954]) { foreach ($group in $AppGroups[954].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[955]) { foreach ($group in $AppGroups[955].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[956]) { foreach ($group in $AppGroups[956].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[957]) { foreach ($group in $AppGroups[957].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[958]) { foreach ($group in $AppGroups[958].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[959]) { foreach ($group in $AppGroups[959].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[960]) { foreach ($group in $AppGroups[960].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[961]) { foreach ($group in $AppGroups[961].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[962]) { foreach ($group in $AppGroups[962].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[963]) { foreach ($group in $AppGroups[963].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[964]) { foreach ($group in $AppGroups[964].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[965]) { foreach ($group in $AppGroups[965].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[966]) { foreach ($group in $AppGroups[966].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[967]) { foreach ($group in $AppGroups[967].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[968]) { foreach ($group in $AppGroups[968].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[969]) { foreach ($group in $AppGroups[969].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[970]) { foreach ($group in $AppGroups[970].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[971]) { foreach ($group in $AppGroups[971].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[972]) { foreach ($group in $AppGroups[972].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[973]) { foreach ($group in $AppGroups[973].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[974]) { foreach ($group in $AppGroups[974].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[975]) { foreach ($group in $AppGroups[975].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[976]) { foreach ($group in $AppGroups[976].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[977]) { foreach ($group in $AppGroups[977].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[978]) { foreach ($group in $AppGroups[978].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[979]) { foreach ($group in $AppGroups[979].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[980]) { foreach ($group in $AppGroups[980].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[981]) { foreach ($group in $AppGroups[981].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[982]) { foreach ($group in $AppGroups[982].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[983]) { foreach ($group in $AppGroups[983].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[984]) { foreach ($group in $AppGroups[984].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[985]) { foreach ($group in $AppGroups[985].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[986]) { foreach ($group in $AppGroups[986].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[987]) { foreach ($group in $AppGroups[987].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[988]) { foreach ($group in $AppGroups[988].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[989]) { foreach ($group in $AppGroups[989].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[990]) { foreach ($group in $AppGroups[990].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[991]) { foreach ($group in $AppGroups[991].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[992]) { foreach ($group in $AppGroups[992].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[993]) { foreach ($group in $AppGroups[993].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[994]) { foreach ($group in $AppGroups[994].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[995]) { foreach ($group in $AppGroups[995].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[996]) { foreach ($group in $AppGroups[996].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[997]) { foreach ($group in $AppGroups[997].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[998]) { foreach ($group in $AppGroups[998].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[999]) { foreach ($group in $AppGroups[999].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
            if ($Comp -like $AppComp[1000]) { foreach ($group in $AppGroups[1000].Split(',')) {Add-ADGroupMember -Identity $group -Members $Comp -Server $DCTieto} }
                                    #}
    } 
    }

    # =============================================================================================================================================== #

    Start-Sleep -Seconds 5

    #=== Scan-To-File ===================================================================================================================== #

    #=== Credentials =====================================================================================================================
    #$User = "crSCRIPT-Migration"
    #$PWord = ConvertTo-SecureString "YrAddHyxZ5m8VvSmZdnQmFFWu64ba4%47dWCrBjPn48Ce8WP" -AsPlainText -Force #"YrAddHyxZ5m8VvSmZdnQmFFWu64ba4%47dWCrBjPn48Ce8WP"
    #$Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $User, $PWord
    #  -Credential $Credential

    #=== Import Module ===
    Import-Module ActiveDirectory
    Import-Module NTFSSecurity

    #$args = "D:\Powershell\Stockholms_Stad\Scan_To_File-1_Rev4.ps1"
    #Start-Process powershell.exe -Credential $Credential -Verb RunAs -ArgumentList ("-file $args")

    #=== Variables ==========================
    #$date = read-host "Enter date in format yyyyMMdd"
    $DCTieto = "wsdc003.ad.stockholm.se"
    #$Masterlist = Import-Csv "D:\PSInData\Users-Migration\BaseFile\combined_$date.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate -Delimiter "," | select -Skip 1
    #$users = $Masterlist.samaccountname
    $remoteFolder = "\\NAS004\te1hf001$"
    #$users = @(Get-ADUser -SearchScope OneLevel -SearchBase "OU=Users,OU=CoS,DC=ad,DC=stockholm,DC=se" -Properties SamAccountName, employeeType  -Filter {((employeeType -like 'F' -or employeeType -like 'K' -or employeeType -like 'O' -or employeeType -like 'V'))} | select SamAccountName,employeeType)
    #$users = Get-ADUser af15949 -Properties SamAccountName, employeeType
    $Masterlist = Import-Csv "D:\PSInData\Users-Migration\BaseFile\combined_$date-1.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate, SthlmFakturaRef -Delimiter "," | select -Skip 1
    $users = $Masterlist.samaccountname

    $ResultsTrue = @()
    $ResultsFalse = @()

    foreach ($user in $users)
    {
        #$UserID = $user.SamAccountName
    
        $TP = test-path "\\NAS004\te1hf001$\$User"
        $UserType = Get-ADUser $user -Properties employeeType | select -ExpandProperty employeeType
   
        if ($UserType -like 'F' -or $UserType -like 'K' -or $UserType -like 'O' -or $UserType -like 'V')
        {
    <#    
            if ($TP -like $True)
            {
                Write-Host "$User has a STF" -ForegroundColor Green
                $ResultsTrue += 1
            }
            else
            {
                Write-Host "$User Doesn't a STF" -ForegroundColor Red
                $ResultsFalse += 1 
            }
    #>
 
    
            if ($TP -like $False)
            {
            Write-Host "$User Doesn't a STF, Creating one now" -ForegroundColor Yellow
            $ResultsTrue += 1
            $fullPath = "$remoteFolder\$User"
    
            # $homeShare = 
            New-Item -path $fullPath -ItemType Directory -force
            # -ea Stop

            #Get-NTFSAccess = $homeShare
            #$acl = Get-Acl $homeShare 

            Add-NTFSAccess -Path $fullPath -Account $User -AccessRights ReadAndExecute, DeleteSubdirectoriesAndFiles
            #$FileSystemRights = [System.Security.AccessControl.FileSystemRights]"ReadAndExecute","DeleteSubdirectoriesAndFiles"
            #$AccessControlType = [System.Security.AccessControl.AccessControlType]::Allow
    
            #$InheritanceFlags = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
            #$PropagationFlags = [System.Security.AccessControl.PropagationFlags]"None"

            #$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule ($User, $FileSystemRights, $InheritanceFlags, $PropagationFlags, $AccessControlType)
            #$acl.AddAccessRule($AccessRule)
            #Set-Acl -Path $homeShare -AclObject $acl #-ea Stop

            Write-Host "$User STF Created" -ForegroundColor Green
    
            }
            else
            {
                Write-Host "$User has a STF" -ForegroundColor Green
                $ResultsTrue += 1
            }

        }
    }

    Write-Host "True" ($ResultsTrue).count
    Write-Host "False" ($ResultsFalse).count
    #$Results
    #>

    # ================================================================================================================= #

    Start-Sleep -Seconds 5

    # === Move Shared folder objects ======================================================================================= #

    # === Set Date ===
    #$date = Read-Host "Input date in format yyyyMMdd"

    #=== Start Transcript ======================================================
    #$TransDate = get-date -Format yyyyMMddHHmm
    Start-Transcript -Path "D:\Logs\SharedFolders\SFO_Transcript_$Date-1.txt" -NoClobber

    #=== Verbose pref ===
    $VerbosePreference = "Continue"
    #=== Import Module ===
    Import-Module ActiveDirectory

    #$Users=import-csv -Path D:\Mikael\Shared-Folder-Mig\Test-To-DS.csv -Delimiter ";"
    $Users = Import-Csv "D:\PSInData\Users-Migration\BaseFile\combined_$Date-1.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate, SthlmFakturaRef -Delimiter "," | select -Skip 1


    $TargetPathGroups = "OU=Storage,OU=ServiceNowGroups,OU=Groups,OU=CoS,DC=ad,DC=stockholm,DC=se"
    $TargetPathSharedFolders = "OU=SharedFolders,OU=CoS,DC=ad,DC=stockholm,DC=se"
    #$DCTieto = "WSDC007.ds.stockholm.se"
    $DCTieto = "wsdc003.ad.stockholm.se"

    foreach ($user in $Users){

    $DN=Get-ADUser $user.SamAccountName | select -ExpandProperty DistinguishedName
    $OwnerOfSharedFolders = Get-ADObject -Filter {(managedBy -like $DN) -and (objectClass -eq "volume")} -SearchBase "OU=SF,OU=Storage,OU=CS,DC=ad,DC=stockholm,DC=se" -SearchScope OneLevel -Server $DCTieto
    
        foreach ($OwnerOfSharedFolder in $OwnerOfSharedFolders){
        #write-host "$OwnerOfSharedFolder"} }
    
        $GroupA = $OwnerOfSharedFolder.Name + "-A"
        $DNGroupA = Get-ADGroup $GroupA -Server $DCTieto | select -ExpandProperty DistinguishedName
        $GroupR = $OwnerOfSharedFolder.Name + "-R"
        $DNGroupR = Get-ADGroup $GroupR -Server $DCTieto | select -ExpandProperty DistinguishedName
        $GroupX = $OwnerOfSharedFolder.Name + "-X"
        $DNGroupX = Get-ADGroup $GroupX -Server $DCTieto | select -ExpandProperty DistinguishedName
        $SFName = $OwnerOfSharedFolder.DistinguishedName
        #write-host "$GroupA,$GroupR,$GroupX"} }
         
        Move-ADObject $DNGroupA -TargetPath $TargetPathGroups -Server $DCTieto #-WhatIf
        Write-host $DNGroupA
        Move-ADObject $DNGroupR -TargetPath $TargetPathGroups -Server $DCTieto #-WhatIf
        Write-Host $DNGroupR
        Move-ADObject $DNGroupX -TargetPath $TargetPathGroups -Server $DCTieto #-WhatIf
        Write-Host $DNGroupX
        Move-ADObject $SFName -TargetPath $TargetPathSharedFolders -Server $DCTieto #-WhatIf
    
        Write-Host $SFName
        #$SFName | Export-Csv D:\Logs\SFO_Checklist_$date.csv
        } 
    }

    #=== Stop Transcript === #
    Stop-Transcript

    # ================================================================================================================= #

    Start-Sleep -Seconds 5

    # === Exchange finnish mailbox move =============================================================================== #

    #Write-Host "NOTE! Please check Date variable before continueing" -ForegroundColor Cyan
    #Read-Host -Prompt "Press any key to continue..."

    #=== Variables ==================
    #$date = read-host "Enter date in format yyyyMMdd"
    $DCTieto = "wsdc003.ad.stockholm.se"
    $Masterlist = Import-Csv "D:\PSInData\Users-Migration\BaseFile\combined_$date-1.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate, SthlmFakturaRef -Delimiter "," | select -Skip 1
    #$Masterlist = Import-Csv "D:\PSInData\Users-Migration\Extra\extra-20190610.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate -Delimiter ";" | select -Skip 1
    $users = $Masterlist.samaccountname

    #=== Credentials =====================================================================================================================
    $User = "crSCRIPT-Migration"
    $PWord = ConvertTo-SecureString "YrAddHyxZ5m8VvSmZdnQmFFWu64ba4%47dWCrBjPn48Ce8WP" -AsPlainText -Force #"YrAddHyxZ5m8VvSmZdnQmFFWu64ba4%47dWCrBjPn48Ce8WP"
    $Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $User, $PWord

    $SessionOpt = New-PSSessionOption -SkipCACheck:$true -SkipCNCheck:$true -SkipRevocationCheck:$true
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://wsex001/powershell/ -Credential $Credential -SessionOption $SessionOpt
    Import-PSSession $Session




    $DCTieto      = "wsdc003.ad.stockholm.se"
    $dateshort    = get-date -Format "MM/dd/yyyy"
    $Time         = " 07:00:00 PM"
    $dateComplete = $dateshort + $Time

    foreach ($Muser in $users){

    Set-MoveRequest -Identity $Muser -CompleteAfter $dateComplete -DomainController $DCTieto #-WhatIf
    }


    <#
    foreach ($Muser in $users){

    get-MoveRequest -Identity $Muser -DomainController $DCTieto | select DistinguishedName,Status
    }

    #>

    Get-PSSession | Remove-PSSession
    #Remove-PSSession $Session
    #exit

    # ======================================================================================================================= #

    Start-Sleep -Seconds 5400

    # === Get data for Repport file ====

    #=== Date for file to run
    #$date = get-date -Date $(get-date).AddDays(1) -Format yyyyMMdd
    #$date = read-host "Enter date in format yyyyMMdd"

    # Test if there is a combined file 
    #$testpath = Test-Path D:\PSInData\Users-Migration\BaseFile\combined_$date-1.csv

    #if ($testpath -eq $False)
    #{
     #   Write-Host "  .:| No combined file exists |:.   " -ForegroundColor Red
    #}
    #else
    #{

    # Preference
    $confirmpreference = "None"
    $VerbosePreference = "Continue"
    #$ProgressPreference = "Continue"

    # Import module
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
    $Masterlist = Import-Csv "D:\PSInData\Users-Migration\BaseFile\combined_$date-1.csv" -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate, SthlmFakturaRef -Delimiter "," | select -Skip 1
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
            $SthlmFakturaRef = $User.SthlmFakturaRef
                        
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
            SthlmFakturaRef     = $SthlmFakturaRef
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
            Clear-Variable -name "SthlmFakturaRef"
        
    }

    # Results to Excel Formated
    $Results | select 'Samaccountname', 'ADUserExists', 'distinguishedName', 'Exchange', 'Skype', 'sthlmVerksamhetsId', 'sthlmForvaltningsNr', 'sthlmKontoTyp', 'userAccountControl', 'employeeType', 'ScanToFile', 'Manager', 'Versamhet', 'SthlmFakturaRef' |`
     Export-csv D:\Logs\Report\User_Mig_Excel_Report_$date.csv -NoTypeInformation -Encoding UTF8 #-ConditionalText $SamColor
    

    # ===================================================================================================================

    start-sleep -Seconds 15

    # === Import-excel report script === #

    #$date = Read-Host "Enter date in format yyyyMMdd"
    #$DefaultDate = get-date -Format yyyyMMdd
    #$defaultValue = $DefaultDate
    #$Date = if ($value = Read-Host -Prompt "Please enter a date OR Enter to set ($defaultValue)") { $value } else { $defaultValue }

    $csv = Import-Csv D:\Logs\Report\User_Mig_Excel_Report_$date-1.csv -Delimiter ',' |`
    #$csv = Import-Csv C:\Users\xxjanerj\Documents\Stockholms_Stad\Logs\Reports\User_Mig_Excel_Report_$date.csv -Delimiter ',' |`
    select Samaccountname, ADUserExists, distinguishedName, Exchange, Skype, sthlmVerksamhetsId, sthlmForvaltningsNr, sthlmKontoTyp, userAccountControl, employeeType, ScanToFile, manager, Versamhet, SthlmFakturaRef

    # Variables
    $Header = New-ConditionalText -ConditionalType ContainsText -ConditionalTextColor Black -BackgroundColor Darkgray -Range "A1:M1"
    $SamAccountNames = New-ConditionalText -ConditionalType ContainsText -ConditionalTextColor Black -BackgroundColor Lightgray -Range "A:A"
    $ADUserInAD = New-ConditionalText -ConditionalType ContainsText 'YES' -ConditionalTextColor wheat -BackgroundColor green -Range "B:B"
    $ADUserNOTInAD = New-ConditionalText -ConditionalType ContainsText 'NO' -ConditionalTextColor DarkRed -BackgroundColor LightPink -Range "B:B"
    $OUText = New-ConditionalText CoS wheat green -Range "C:C"
    $Exchange_1 = New-ConditionalText EXDAG01 wheat green -Range "D:D"
    $Exchange_2 = New-ConditionalText EXDAG02 wheat green -Range "D:D"
    $Exchange_3 = New-ConditionalText -ConditionalType NotEqual EXDAG01 -ConditionalTextColor DarkRed -BackgroundColor LightPink -Range "D:D"
    $Exchange_4 = New-ConditionalText -ConditionalType ContainsText mdb -ConditionalTextColor DarkRed -BackgroundColor LightPink -Range "D:D"
    $Skype_1 = New-ConditionalText '2:1' wheat green
    $Skype_2 = New-ConditionalText '3:1' wheat green
    $SthlmVerksamhetsID = New-ConditionalText -ConditionalType GreaterThan '1' -ConditionalTextColor wheat -BackgroundColor green -Range "F:F"
    $SthlmForvaltningsNr = New-ConditionalText -ConditionalType GreaterThan '1' -ConditionalTextColor wheat -BackgroundColor green -Range "G:G"
    $userAccountControl_1 = New-ConditionalText 262656 blue cyan -Range "I:I"
    $userAccountControl_2 = New-ConditionalText 512 cyan blue -Range "I:I"
    $userAccountControl_3 = New-Conditionaltext -ConditionalType GreaterThan '1' orange -Range "I:I"
    $sthlmKontoTyp = New-ConditionalText -ConditionalType ContainsText '0' -ConditionalTextColor wheat -BackgroundColor green -Range "H:H"
    $employeeType = New-ConditionalText -ConditionalType GreaterThan '1' -ConditionalTextColor wheat -BackgroundColor green -Range "J:J"
    $ScanToFileTrue = New-ConditionalText -ConditionalType ContainsText 'True' -ConditionalTextColor wheat -BackgroundColor green -Range "K:K"
    $ScanToFileFalse = New-ConditionalText -ConditionalType ContainsText 'False' -ConditionalTextColor DarkRed -BackgroundColor LightPink -Range "K:K"
    $ManagerGreen = New-ConditionalText CoS wheat green -Range "L:L"
    $ManagerRed = New-ConditionalText '' -ConditionalTextColor DarkRed -BackgroundColor LightPink -Range "L:L"
    $Versamhet = New-ConditionalText -ConditionalType GreaterThan '1' -ConditionalTextColor wheat -BackgroundColor green -Range "M:M"
    $SthlmFakturaRef = New-ConditionalText -ConditionalType GreaterThan '1' -ConditionalTextColor wheat -BackgroundColor green -Range "N:N"

    # Out Excel file
    #$csv | Export-Excel C:\Users\xxjanerj\Documents\Stockholms_Stad\Logs\Reports\Cos_Users_Excel_Report_$date.xlsx -FreezeTopRow -BoldTopRow -Show -AutoSize -AutoFilter -ConditionalText $Header, $SamAccountNames, $ADUserInAD, $ADUserNOTInAD, $OUText, $Exchange_1, $Exchange_2, $Exchange_3, $Exchange_4, $Skype_1, $Skype_2, $SthlmVerksamhetsID, $SthlmForvaltningsNr, $userAccountControl_1, $userAccountControl_2, $userAccountControl_3, $sthlmKontoTyp, $employeeType, $ScanToFileTrue, $ScanToFileFalse, $ManagerGreen, $ManagerRed, $Versamhet
    $csv | Export-Excel D:\Logs\Report\Excel_Reports\Cos_Users_Excel_Report_$date.xlsx -FreezeTopRow -BoldTopRow -Show -AutoSize -AutoFilter -ConditionalText $Header, $SamAccountNames, $ADUserInAD, $ADUserNOTInAD, $OUText, $Exchange_1, $Exchange_2, $Exchange_3, $Exchange_4, $Skype_1, $Skype_2, $SthlmVerksamhetsID, $SthlmForvaltningsNr, $userAccountControl_1, $userAccountControl_2, $userAccountControl_3, $sthlmKontoTyp, $employeeType, $ScanToFileTrue, $ScanToFileFalse, $ManagerGreen, $ManagerRed, $Versamhet, $SthlmFakturaRef
    #  -Show
    # Rm Test_Excel_Rev1.xlsx -ErrorAction Ignore

    # -Show -AutoSize NotEqual

    # ======================================================================================================================= #

    # === Stop Transcript ===
    Stop-Transcript

    # === Stop excel processes ===
    Stop-Process -name "excel"

    Start-sleep -Seconds 300

    # === Send Report ===
    $recipients = "LKA <LKA@Tieto.com>, Aaltonen Jyri <Jyri.Aaltonen@tieto.com>, Andersson Mikael (Ext) <ext.mikael.andersson@tieto.com>, Bengtsson Anders <Anders.Bengtsson@tieto.com>, Bilan Vojtech <Vojtech.Bilan@tieto.com>, Bolacky Jiri <Jiri.Bolacky@tieto.com>, Burlin Patrik <Patrik.Burlin@tieto.com>, Drexler Dominik <dominik.drexler@tieto.com>, Hogberg Marika <marika.hogberg@tieto.com>, Janers Jack (Ext) <ext.jack.janers@tieto.com>, Jurcik Jan <Jan.Jurcik@tieto.com>, Karlsson Jan <Jan.Karlsson@tieto.com>, Landberg Patrik <Patrik.Landberg@tieto.com>, Mikunda Marek <Marek.Mikunda@tieto.com>, Stoces Jan <Jan.Stoces@tieto.com>, Waesterberg Jenny <Jenny.Waesterberg@tieto.com>, Wall Michael <Michael.Wall@tieto.com>, Widahl Markus <markus.widahl@tieto.com>, Zwyrtek Martin <martin.zwyrtek@tieto.com>".Split(',')
    Send-MailMessage -From 'AD-Team <AD.NoReply@Tieto.com>' -To $recipients -Cc 'Bengt Jonsson <ext.bengt.jonsson@tieto.com>' -Subject "Usermigration $date-1" -Body "Here is tonight's Usermigration Report $Date. `n `nRegards `nJack" -Attachments "D:\Logs\Report\Excel_Reports\Cos_Users_Excel_Report_$date-1.xlsx"  -SmtpServer 'extrelay.stockholm.se' -Port '25'
    # -Bcc '<jack.janers@centricsweden.se>'

    # === Archive file that just ran ===
    Move-Item -Path D:\PSInData\Users-Migration\BaseFile\combined_$date-1.csv -Destination D:\PSInData\Users-Migration\BaseFile\Migrated

    # === Rename Employeetype O Accounts ===
    # === Variables ===
    #$Date = get-date -Format yyyyMMdd
    $ParaplyFunk = "Funktionskonto för ParaplyPC"
    $NoResourceFunk = "Funktionskonto helt utan resurser"
    $AllResourceFunk = "Funktionskonto med mail skype"

    # === Prod Take out list ===
    $dctieto = "wsdc003.ad.stockholm.se"
    #$Users = Get-ADUser -Filter {employeeType -like "o" -and pager -eq "NEED_TIETO_ONBOARDING" } -SearchBase "OU=Users,OU=CoS,DC=ad,DC=stockholm,DC=se" -Properties SamAccountName,displayName,Name,givenName,sn,employeeType,manager,description,sthlmKontoTyp,sthlmVerksamhetsId,uid,userAccountControl,extensionAttribute14,extensionAttribute15,sthlmForvaltningsNr,pager
    $Users = Get-ADUser -Filter {employeeType -like "o" -and pager -eq "NEED_TIETO_ONBOARDING" } -SearchBase "OU=Users,OU=CoS,DC=ad,DC=stockholm,DC=se" -Properties employeeType,pager

    $users | %{get-aduser $_.SamAccountName  -Properties * -Server $dctieto | select SamAccountName,displayName,Name,givenName,sn,employeeType,manager,description,sthlmKontoTyp,sthlmVerksamhetsId,uid,userAccountControl,extensionAttribute14,extensionAttribute15,sthlmForvaltningsNr,pager,homeDirectory,msExchHomeServerName,msRTCSIP-PrimaryHomeServer,account*} |
    export-csv -Path "D:\Logs\Report\AD-UsersType-o-Convert_$date.csv" -Encoding UTF8 -Delimiter ";" -NoTypeInformation

    # === Backup ===
    Copy-Item "D:\Logs\Report\AD-UsersType-o-Convert_$date.csv" -Destination "D:\Backup\O_Accounts_Backup\"
    Rename-Item "D:\Backup\O_Accounts_Backup\AD-UsersType-o-Convert_$date.csv" -NewName "D:\Backup\O_Accounts_Backup\O_Accounts_Backup_$date.csv"

    # === Import lists for Looping ===
    $ChangeOUsers = Import-Csv -Path "D:\Logs\Report\AD-UsersType-o-Convert_$date.csv" -Delimiter ";" -Header SamAccountName,displayName,Name,givenName,sn,employeeType,manager,description,sthlmKontoTyp,sthlmVerksamhetsId,uid,userAccountControl,extensionAttribute14,extensionAttribute15,sthlmForvaltningsNr,pager,homeDirectory,msExchHomeServerName,msRTCSIP-PrimaryHomeServer,account* | select -Skip 1
    $ParaplyUsers = import-csv "D:\PSInData\Users-Migration\Convert-UserType\Paraply-Account.csv" -Delimiter ";" -Header Name,DisplayName,SN,GivenName,Company,Department

    #$disp = @()
    # === Loop and change users ===
    foreach ($ChangeOUser in $ChangeOUsers)
    {
        #$U = Get-ADUser "$ChangeOUser" -Properties SamAccountName, GivenName, Surname, Displayname, msExchHomeServerName, msRTCSIP-PrimaryHomeServer
        #$U
        $Sam = $ChangeOUser.SamAccountName
        $givenname = $ChangeOUser.GivenName
        $Surname = $ChangeOUser.Sn
        $Displayname = $ChangeOUser.Displayname

        #$Sam
        #$givenname
        #$Surname
        #$Displayname

        #}
       
        #OLDLINE #$ChangeOSam = Get-ADUser $ChangeOUser.SamAccountName | select -ExpandProperty samaccountname
    
        $NewGivenName = $givenname + " " + $Surname
        Set-ADUser "$Sam" -Replace @{GivenName = "$NewGivenName"} -Server $dctieto #-WhatIf
        #OLDLINE #Set-ADUser -Identity $changeOUser.SamAccountName -GivenName $NewGivenName -Server $dctieto
    
        if ($ParaplyUsers.Name -contains $Sam)
        {
            #Write-Host "$Sam $ParaplyFunk" -ForegroundColor Green
            Set-ADUser "$Sam" -Replace @{sn = "$ParaplyFunk"} -Server $dctieto #-WhatIf
            #OLDLINE #Set-ADUser -Identity $ChangeOSam -Surname $ParaplyFunk
            #*** NEW DisplayName Function ***
            $NewDisplayname = $NewGivenName + " " + $ParaplyFunk
            Set-ADUser "$Sam" -Replace @{DisplayName = "$NewDisplayname"} -Server $dctieto #-WhatIf
            #OLDLINE #Set-ADUser -Identity $ChangeOSam -DisplayName $NewDisplayname
        }
        else
        {
            $user = Get-ADUser $Sam -Properties msExchHomeServerName
            if($user.PSObject.Properties.Match('msExchHomeServerName').Count)
            #((get-aduser "$Sam" -properties msExchHomeServerName,"msRTCSIP-PrimaryHomeServer" | where {($_.msExchHomeServerName -eq $False) -and ($_."msRTCSIP-PrimaryHomeServer" -eq $False)}) -like $True)
            #(Get-Member -InputObject $Sam -Name msExchHomeServerName -MemberType Properties)
            #if ((get-aduser "$Sam" -properties msExchHomeServerName,"msRTCSIP-PrimaryHomeServer" | where {($_.msExchHomeServerName -eq $null) -or ($_."msRTCSIP-PrimaryHomeServer" -eq $null)}) -like $True)
        #{
        #       Write-Host "SomeProperty: $($testObject.SomeProperty)"
        #}
            { #and
                #Write-Host "$Sam $AllResourceFunk" -ForegroundColor DarkCyan
                Set-ADUser "$Sam" -Replace @{sn = "$AllResourceFunk"} -Server $dctieto #-WhatIf
                #OLDLINE #Set-ADUser -Identity $ChangeOSam -Surname $AllResourceFunk
                #*** NEW DisplayName Function ***
                $NewDisplayname = $NewGivenName + " " + $AllResourceFunk
                Set-ADUser "$Sam" -Replace @{DisplayName = "$NewDisplayname"} -Server $dctieto #-WhatIf
                #OLDLINE #Set-ADUser -Identity $ChangeOSam -DisplayName $NewDisplayname
            }
    
            else
            {
                #Write-Host "$Sam $NoResourceFunk" -ForegroundColor Cyan
                Set-ADUser "$Sam" -Replace @{sn = "$NoResourceFunk"} -Server $dctieto #-WhatIf
                #OLDLINE #Set-ADUser -Identity $ChangeOSam -Surname $NoResourceFunk
                #*** NEW DisplayName Function ***
                $NewDisplayname = $NewGivenName + " " + $NoResourceFunk
                Set-ADUser "$Sam" -Replace @{DisplayName = "$NewDisplayname"} -Server $dctieto #-WhatIf
                #OLDLINE #Set-ADUser -Identity $ChangeOSam -DisplayName $NewDisplayname
            
            }
        }
                #Write-Host " "
                #Get-ADUser $sam -Properties SamAccountName,GivenName,Surname,Displayname | select SamAccountName,GivenName,Surname,Displayname
                #Write-Host " "
    }

    Remove-Item "D:\Logs\Report\AD-UsersType-o-Convert_$date.csv"
}
else
{
    Exit
}
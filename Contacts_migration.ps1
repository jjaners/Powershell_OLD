# === Contacts migration ===

#=== Connect to WebService ===========================================================================================================
#=== Credentials =====================================================================================================================
$User = "crSCRIPT-Migration"
$PWord = ConvertTo-SecureString "YrAddHyxZ5m8VvSmZdnQmFFWu64ba4%47dWCrBjPn48Ce8WP" -AsPlainText -Force #"YrAddHyxZ5m8VvSmZdnQmFFWu64ba4%47dWCrBjPn48Ce8WP"
$Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $User, $PWord

#=== Connect to WebService ===========================================================================================================
$Pxy = New-WebServiceProxy -Uri "http://ws00970.ad.stockholm.se/HCL.Sthlm.MigrationServices.Service/MigrationServices.svc" -Credential $Credential -Namespace WsProxy

# === Move contacts user object through web service ===
#Import users.
#$User="AB67959"
    $InitialDirectory = "D:\PSInData\Contacts_Migration"
    param(

        [Parameter(ValueFromPipeline = $true, HelpMessage = "Enter CSV path(s)")]
        [String[]]$Path = $null
    )

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

$ContactList = import-csv -Path $Path -Delimiter ";"

# === Envirement settings ===
#Comment are the same. It just that we need to have something.
$Comment = "GSIT2.0"
#$DCTieto = "wsdc003.ad.stockholm.se"
$DCTieto = "ws00002.ad.stockholm.se"

$ToDayDate = Get-Date -Format "yyyyMMdd-HHmm"
$Batchname = "Shared-Mailbox-Log-$ToDayDate"

# === Call out of HCL webservice ===
##### ÄNDRA SHAREDMAILBOX till Contacts #####
$Results = @()
foreach ($Contact in $ContactList){
$samaccountname = $Contact.SamAccountName

$results01 = $Pxy.MigrateMsxResource($samaccountname,$Comment)

$Results += $results01
}

#$Results | Out-GridView
$Results | export-csv -Path D:\Logs\Contacts_Migration\$Batchname.csv -Delimiter ";" -Encoding UTF8 -NoTypeInformation

start-sleep -s 60
#Read-Host -Prompt "Press Enter to proceed"
#####STOP HERE AND WAITE FORE THE OBJECT IN DMZ#################

Write-Host "Number in file "$ContactList.count"st"
Write-Host "-------------------------------------------------------------"
write-host "NUmber of ContactLists in DMZ from File" (Get-ADObject -LDAPFilter “objectClass=Contact” -SearchBase "OU=Users,OU=Tieto,OU=DMZ,DC=ad,DC=stockholm,DC=se").count""
#write-host "NUmber of ContactLists in DMZ from File"($ContactList | %{Get-ADUser $_.samaccountname -Server $DCTieto} | where DistinguishedName -Like "*OU=Users,OU=Tieto,OU=DMZ,DC=ad,DC=stockholm,DC=se").count""
#write-host "NUmber of ContactLists in DMZ from File"($ContactList | %{Get-ADObject $_.name -LDAPFilter “objectClass=Contact” -SearchBase "OU=Users,OU=Tieto,OU=DMZ,DC=ad,DC=stockholm,DC=se" -SearchScope OneLevel}).count""
#Get-ADObject -Filter {name -eq "mkae77595"} -SearchBase "OU=Users,OU=Tieto,OU=DMZ,DC=ad,DC=stockholm,DC=se" -SearchScope OneLevel


# === Move Object to User OU ===
#$DCTieto = "wsdc003.ad.stockholm.se"
$users = $ContactList.SamAccountName

foreach ($User in $Users)
{
      #  Write-Host "$user"}

    #$UserSam = Get-ADUser -Identity $user | select samaccountname
    $DN = Get-ADObject -Filter {name -eq $User} -SearchBase "OU=Users,OU=Tieto,OU=DMZ,DC=ad,DC=stockholm,DC=se" -SearchScope OneLevel -Properties distinguishedname -Server $DCTieto | select -ExpandProperty distinguishedname
    #$DN = Get-ADUser $user -Properties distinguishedname -Server $DCTieto | select -ExpandProperty distinguishedname
    #Write-Host "$DN"
    # Move to Users_JJ
    Move-ADObject -Identity "$DN" -TargetPath "OU=ServiceNowContacts,OU=Contacts,OU=CoS,DC=ad,DC=stockholm,DC=se" -Server $DCTieto
    
}

<#
# === Set Attribribute on the User Objects ===
$users = $ContactList
foreach ($User in $Users)
{
    $U = $user.SamAccountName
    #$X = $User.NoSmartcardreq
    # Write-Host $U, $X }
        
    # === Per user variables ===
    #$employeeType = Get-ADUser $U -Properties employeeType -Server $DCTieto | select -ExpandProperty employeeType
   #$NoSmartcardreq = Get-ADUser $U -Properties employeeType -Server $DCTieto | select -ExpandProperty employeeType
    
    # Need to set this first. Michael want this to be on the account before object are moved to Users.
    set-aduser -Identity $U -Replace @{Pager="NEED_TIETO_ONBOARDING"} -Server $DCTieto

    # === Remove Homedrirectory and Homedrive ===
    #set-aduser -Identity $U -Clear HomeDirectory -Server $DCTieto
    #Set-ADUser -Identity $U -Clear HomeDrive -Server $DCTieto
    
    #Make sthlmVerksamhetsId same as sthlmForvaltningsNr  
    #$GetUser = Get-ADUser $U -Properties sthlmVerksamhetsId, sthlmForvaltningsNr -Server $DCTieto
    #$GetUser | %{Set-ADUser $U -Replace @{sthlmVerksamhetsId = $GetUser.sthlmForvaltningsNr} -Server $DCTieto}

    #Empty this value sthlmKontoTyp
    #Set-ADUser $U -Clear sthlmKontoTyp -Server $DCTieto

    #Set employeetype to m
    #Set-ADUser $U -Replace @{employeeType = "m"} -Server $DCTieto

}

#>

Move-Item -Path $Path -Destination "D:\PSInData\Contacts_Migration\Done\"
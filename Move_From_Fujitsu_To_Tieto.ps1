################### MOVE FROM FUJITSU TO TIETO #########################################

#Credentials to use.
$User = "crSCRIPT-Migration"
$PWord = ConvertTo-SecureString "YrAddHyxZ5m8VvSmZdnQmFFWu64ba4%47dWCrBjPn48Ce8WP" -AsPlainText -Force #"YrAddHyxZ5m8VvSmZdnQmFFWu64ba4%47dWCrBjPn48Ce8WP"
$Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $User, $PWord

$SessionOpt = New-PSSessionOption -SkipCACheck:$true -SkipCNCheck:$true -SkipRevocationCheck:$true
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://wsex001/powershell/ -Credential $Credential -SessionOption $SessionOpt
Import-PSSession $Session


#Account that should be moved
#Global settings
$UserstoMoveFJtoTieto = "af10438"
$DCtieto = "wsdc003"

#Move the account to DMZ
$FujitsuUserprefex = $UserstoMoveFJtoTieto + "x"
Get-ADUser $FujitsuUserprefex -Server $DCtieto | Move-ADObject -TargetPath "OU=Users,OU=Tieto,OU=DMZ,DC=ad,DC=stockholm,DC=se" -Server $DCtieto

#Change samaccountname
Get-ADUser $FujitsuUserprefex -Server $DCtieto | Set-ADUser -SamAccountName $UserstoMoveFJtoTieto -Server $DCtieto -PassThru

#Clear targetAddress
Get-ADUser $UserstoMoveFJtoTieto -Server $DCtieto | Set-ADUser -Clear targetAddress -Server $DCtieto

#List proxyAddresses
#Get-ADUser $UserstoMoveFJtoTieto -Properties proxyAddresses -Server $DCtieto | select -ExpandProperty proxyAddresses

$Proxyaddress = Get-ADUser $UserstoMoveFJtoTieto -Properties proxyAddresses -Server $DCtieto | select -ExpandProperty proxyAddresses
$Removeproxyaddress = $Proxyaddress | where {$_ -like "*@edu.stockholm.se" -or $_ -like "x500*"}

#Remove address in proxyAddresses. Remove x500 and the adress edu.stockholm.se
#Get-ADUser $UserstoMoveFJtoTieto -Properties proxyAddresses -Server $DCtieto | Set-ADUser -Remove @{proxyAddresses="X500:/o=Stockholm EDU/ou=Exchange Administrative Group (FYDIBOHF23SPDLT)/cn=Recipients/cn=mogos.senay"} -Server $DCtieto

foreach ($remove in $Removeproxyaddress)
{
Write-Host "User $UserstoMoveFJtoTieto proxyaddress are removed $remove"
Set-ADUser -Identity $UserstoMoveFJtoTieto -Remove @{proxyAddresses = "$remove"} -Server $DCtieto

}


#Move mailbox to Tieto
$Tietodatabase = "EXDAG01-DB27"

get-mailbox $UserstoMoveFJtoTieto | Remove-MoveRequest -Confirm:$false
New-MoveRequest -Identity $UserstoMoveFJtoTieto  -TargetDatabase $Tietodatabase -BadItemLimit 100

Get-MoveRequest $UserstoMoveFJtoTieto

#Build the script for migration
$myArray = @()
$accounttype = (get-aduser $UserstoMoveFJtoTieto -Properties employeeType -Server $DCtieto | select employeeType).employeeType
#$MoveDate = "2019-10-03"
$ToDayDate = Get-Date -Format "yyyyMMdd-HHmm"
$MoveDate = Get-Date -Format "yyyyMMdd"
$FileDateSuffix = "$ToDayDate" + ".csv"

$myObject2 = New-Object System.Object

$myObject2 | Add-Member -type NoteProperty -name samaccountname -Value "$UserstoMoveFJtoTieto"
$myObject2 | Add-Member -type NoteProperty -name Accounttype -Value "$accounttype"
$myObject2 | Add-Member -type NoteProperty -name NoSmartcardreq -Value ""
$myObject2 | Add-Member -type NoteProperty -name UserMoveDate -Value "$MoveDate"

$myArray += $myobject2

#Create the migfile. Put the file in usermigration cat and create the basefile through the menu.
$myArray | Export-Csv -Path D:\Powershell\Mikael\Move-Users-Between-Deleverys\SPV-FOB\Mig-List\MigList-SPV-FOB-$FileDateSuffix -Delimiter ";" -Encoding UTF8 -NoTypeInformation



﻿
Function DecodeUserAccountControl ([int]$UAC)
{
$UACPropertyFlags = @(
"SCRIPT",
"ACCOUNTDISABLE",
"RESERVED",
"HOMEDIR_REQUIRED",
"LOCKOUT",
"PASSWD_NOTREQD",
"PASSWD_CANT_CHANGE",
"ENCRYPTED_TEXT_PWD_ALLOWED",
"TEMP_DUPLICATE_ACCOUNT",
"NORMAL_ACCOUNT",
"RESERVED",
"INTERDOMAIN_TRUST_ACCOUNT",
"WORKSTATION_TRUST_ACCOUNT",
"SERVER_TRUST_ACCOUNT",
"RESERVED",
"RESERVED",
"DONT_EXPIRE_PASSWORD",
"MNS_LOGON_ACCOUNT",
"SMARTCARD_REQUIRED",
"TRUSTED_FOR_DELEGATION",
"NOT_DELEGATED",
"USE_DES_KEY_ONLY",
"DONT_REQ_PREAUTH",
"PASSWORD_EXPIRED",
"TRUSTED_TO_AUTH_FOR_DELEGATION",
"RESERVED",
"PARTIAL_SECRETS_ACCOUNT"
"RESERVED"
"RESERVED"
"RESERVED"
"RESERVED"
"RESERVED"
)
$Attributes = ""
1..($UACPropertyFlags.Length) | Where-Object {$UAC -bAnd [math]::Pow(2,$_)} | ForEach-Object {If ($Attributes.Length -EQ 0) {$Attributes = $UACPropertyFlags[$_]} Else {$Attributes = $Attributes + " | " + $UACPropertyFlags[$_]}}
Return $Attributes
}

$users = @(Get-ADUser -SearchScope OneLevel -SearchBase "OU=Users,OU=CoS,DC=ad,DC=stockholm,DC=se"´
 -Properties SamAccountName, givenname, surname, sthlmForvaltningsNr, userAccountControl -Filter * |´
  select SamAccountName, givenname, surname, sthlmForvaltningsNr, userAccountControl, @{n='UsrAcCtrl';e={DecodeUserAccountControl($_.userAccountControl)}})
# {((employeeType -like 'F' -or employeeType -like 'K' -or employeeType -like 'O' -or employeeType -like 'V'))}

$users 
#| export-csv D:\Logs\Report\SmartCard_Report.csv -Delimiter ";"

# ft -AutoSize
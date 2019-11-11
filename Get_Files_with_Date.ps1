# Get in files with -1 day date

#$Date_1 = Get-Date -date $(get-date).adddays(-1) -format yyyy-MM-dd
#$date = "20190610"
$date = Read-Host "Input date in format yyyyMMdd"
$FilesShare = "\\WSADMGMT01\PSInData\Users-Migration\"

#$ScanedFile = Get-ChildItem -Path $FilesShare "*$date*" | select $_.name

#$list = Get-Content $ScanedFile

#-Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate
#   | ForEach-Object {$_ -replace '"','""'} 
# | ConvertTo-Csv -NoTypeInformation | % {$_.Replace('"','')} | Out-File \\seps01\Powershell\PS_Result\Server_inventory.csv
# 
$Combine = Get-ChildItem -Path $FilesShare "*$date*"`
 | Select-Object -ExpandProperty FullName | Import-Csv -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate -Delimiter ";" | select -Skip 1 `
| Export-Csv "D:\PSInData\Users-Migration\BaseFile\combined_$date.csv" -NoTypeInformation -NoClobber -Append

$CombineClean = Import-Csv "D:\PSInData\Users-Migration\BaseFile\combined_$date.csv" #| select -Skip 1

#RM "D:\PSInData\Users-Migration\BaseFile\combined_$date.csv"

#$CC = $CombineClean -replace '"',''

#$CC | export-csv "D:\PSInData\Users-Migration\BaseFile\combined_$date ver2.csv" -NoTypeInformation

# $CombineClean | Where-Object {($_.NoSmartcardreq -like "x") -and (($_.accounttype -like "O" -or $_.accounttype -like "F"))} | select samaccountname, accounttype, NoSmartcardreq -First 20


foreach ($Row in $CombineClean)
{
# ====== Account typ F/V/K ===================================================================================================    
    
if ($Row | Where-Object { (($_.accounttype -like "F" -or $_.accounttype -like "V" -or $_.accounttype -like "K"))  })
    # | select samaccountname, accounttype, NoSmartcardreq)
    #(($row.Accounttype -like "F" -or $row.Accounttype -like "V" -or $row.Accounttype -like "K"))
    {
       $Users = $Row.Samaccountname
       # write-host "$Users"
       
       # Move users from DMZ to Tieto OU Script (Steg 1)
       D:\Powershell\Stockholms_Stad\Move_Users_To_UsersOU.ps1

       # Set and clear Attributes
       D:\Powershell\Stockholms_Stad\Set-Attributes.ps1

       # Add users to Application groups (lägg till grupper från steg 2)
       D:\Powershell\Stockholms_Stad\AddTo_AppsGroups.ps1

       # Add Users to Groups that all users should have
       D:\Powershell\Stockholms_Stad\Add_users_to_Groups_all_Users.ps1

       # Groupe translation script for adding users from HCL to Tieto groups
       D:\Powershell\Stockholms_Stad\If_In_GroupA_Add_To_GroupeB_rev1.ps1
       
       If ($Row.NoSmartcardreq -like "x")
       {
       Set-ADUser $Row.SamAccountname -Replace @{userAccountControl = "262656"} -Server $DCTieto
       }
       # ($_.NoSmartcardreq -like "x")
       # Write-Host "$row"
       # $row | out-string
    }
        
# ====== Account typ L ===================================================================================================        
     
if ($Row | Where-Object { ($_.accounttype -like "L") })
        # | select samaccountname, accounttype, NoSmartcardreq)
        #(($row.Accounttype -like "F" -or $row.Accounttype -like "V" -or $row.Accounttype -like "K"))
    {
       $Users = $Row.Samaccountname
       # write-host "$Users"
      
       # Move users from DMZ to Tieto OU Script (Steg 1)
       D:\Powershell\Stockholms_Stad\Move_Users_To_UsersOU.ps1

       # Set and clear Attributes
       D:\Powershell\Stockholms_Stad\Set-Attributes.ps1

       # Add users to Application groups (lägg till grupper från steg 2)
       D:\Powershell\Stockholms_Stad\AddTo_AppsGroups.ps1

       # Add Users to Groups that all users should have
       D:\Powershell\Stockholms_Stad\Add_users_to_Groups_all_Users.ps1

       # Groupe translation script for adding users from HCL to Tieto groups
       D:\Powershell\Stockholms_Stad\If_In_GroupA_Add_To_GroupeB_rev1.ps1
       
       Set-ADUser $Row.SamAccountname -Replace @{employeeType = "k"} -Server $DCTieto

       If ($Row.NoSmartcardreq -like "x")
       {
       Set-ADUser $Row.SamAccountname -Replace @{userAccountControl = "262656"} -Server $DCTieto
       }
    }

# ====== Account typ O ===================================================================================================

if ($Row | Where-Object { ($_.accounttype -like "O") })
        # | select samaccountname, accounttype, NoSmartcardreq)
        #(($row.Accounttype -like "F" -or $row.Accounttype -like "V" -or $row.Accounttype -like "K"))
    {
       $Users = $Row.Samaccountname
       # write-host "$Users"
      
       # Move users from DMZ to Tieto OU Script (Steg 1)
       D:\Powershell\Stockholms_Stad\Move_Users_To_MigratedOU.ps1

       # Set and clear Attributes
       D:\Powershell\Stockholms_Stad\Set-Attributes.ps1

       # Add users to Application groups (lägg till grupper från steg 2)
       D:\Powershell\Stockholms_Stad\AddTo_AppsGroups.ps1

       # Add Users to Groups that all users should have
       D:\Powershell\Stockholms_Stad\Add_users_to_Groups_all_Users.ps1

       # Groupe translation script for adding users from HCL to Tieto groups
       D:\Powershell\Stockholms_Stad\If_In_GroupA_Add_To_GroupeB_rev1.ps1
       
       If ($Row.NoSmartcardreq -like "x")
       {
       Set-ADUser $Row.SamAccountname -Replace @{userAccountControl = "262656"} -Server $DCTieto
       }
        
        
}


<#
foreach ($file in $ScanedFile)
{
  #Write-Host "$File"
  $Contents = Get-Content $file
  $list = @()

  $list += $Contents | select -Skip 1

}
#>  


<#
$Contents = Get-Content "Path\test.txt"
$list = @()

foreach($Line in $Contents) {
  $Line = $Line.split(":")[1]
  $s = $line -split ':'
  $RegPath = $s[0]
  $Value_Name = $s[1]
  $Type = $s[2]
  $Value = $s[3]
  Write-host $RegPath $Value_Name $Type $Value

  $list += @{Regpath=$Regpath;Name=$Value_Name;Type=$Type;Value=$Value}
}
#>
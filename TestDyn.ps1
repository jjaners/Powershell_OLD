

$users = Get-Content C:\Powershell\PS_Results\TestLoop.txt
#$users = Get-Content C:\Powershell\PS_Results\All_AD_Samaccountnames.txt
#$users = "ae96652"
#$users = "abc7337","ae96652"
#$users = Get-ADUser -Filter * | select samaccountname -First 10

foreach ($User in $Users)
{
    $User1 = get-aduser $user | select -ExpandProperty samaccountname
    
      $Groups = Get-ADPrincipalGroupMembership -Identity $User1 #| select -ExpandProperty samaccountname

    if($Groups -like '*dyn*') {
      $Outputstring1 = "$User1; contains DYN groups"
      $Outputstring1 | out-file C:\Powershell\PS_Results\DYN_Users.txt -Append
      #Export-Csv C:\Powershell\PS_Results\DYN_Users.csv -Append -Delimiter ";"
      #Write-Host "$user contains DYN groups" -ForegroundColor Green
    } else {
      $Outputstring2 = "$User1; does not contains DYN groups"
      $Outputstring2 | out-file C:\Powershell\PS_Results\DYN_Users.txt -Append
      #Export-Csv C:\Powershell\PS_Results\DYN_Users.csv -Append -Delimiter ";"
      
      
      #Write-Host "$user does not contain DYN groups" -ForegroundColor Red
    }
    
     # | where {Samaccountname -like 'tieto*'}
}
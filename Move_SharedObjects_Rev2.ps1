# Shared folder volumes
$SFOVolume = @(
Get-ADObject -Filter {((ObjectClass -like 'volume') -or (ObjectClass -like 'group'))} -SearchBase "OU=SF,OU=Storage,OU=CS,DC=ad,DC=stockholm,DC=se"`
 -Properties Name,ObjectClass,Managedby | select Name,ObjectClass,Managedby

#Get-ADObject -Filter {(ObjectClass -like 'volume')} -SearchBase "OU=SF,OU=Storage,OU=CS,DC=ad,DC=stockholm,DC=se"`
 #-Properties Name,ObjectClass,Managedby | select Name,ObjectClass,Managedby
 )
 $SFOName = $SFOVolume.Name
 $SFOManagedBy = $SFOVolume.ManagedBy

    $CombineSam = @(
    Import-Csv D:\PSInData\Users-Migration\BaseFile\combined_20190610.csv -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate -Delimiter "," | select SamAccountName -Skip 1
    )
    $SamAccountName = $CombineSam.SamAccountName

foreach ($Sam in $SamAccountName)
{
    foreach ($SFOV in $SFOVolume)
    {
     $SFOVcos += $SFOV.Where(({$_.ManagedBy -match 'OU=Users,OU=CoS,DC=ad,DC=stockholm,DC=se'} -and {$_.ManagedBy -like "$Sam"}))
    #$SFOVcos   
    }
    
}
$SFOVcos | export-csv D:\PSInData\Shared-folders\SF_testlist_20190610.csv
#AC95674
#foreach ($SFOVc in $SFOVcos)
#{
#    $SFOVc.Where({$_.ManagedBy -match "$samaccountname"})
#    Write-Host "$SFOVcos"
#}



#ForEach-Object $SFOVcos.Where({$_.ManagedBy -match "$samaccountname"})


<#
ForEach ($SFOV in $SFOVolume)
{
    foreach ($Sam in $SamAccountName)
{
        
        
        
        if ($SFOVolume -match "$Sam") 
          {

            foreach ($SFV in $SFOVolume)
            {
              Write-Host "$SFOV"
              #else {Write-Host No Match}
            }
          }
}
}
#>



<#
#$Array = @(
foreach ($Sam in $SamAccountName)
{
    foreach ($SFOM in $SFOManagedBy)
    {
      if ($SFOManagedBy -match "$Sam") {Write-Host "$SFOName"} #else {Write-Host No Match}
        
    }
       
}
#)
#$Array | FL

$SFO = @(
Get-ADObject -Filter {((ObjectClass -like 'volume') -or (ObjectClass -like 'group'))} -SearchBase "OU=SF,OU=Storage,OU=CS,DC=ad,DC=stockholm,DC=se"`
 -Properties Name,ObjectClass,Managedby | select Name,ObjectClass,Managedby
 )
 $SFOName = $SFO.Name
 $SFOManagedBy = $SFO.ManagedBy
# $SFOManagedBy | select -First 5


$CombineSam = @(
Import-Csv D:\PSInData\Users-Migration\BaseFile\combined_20190610.csv -Header SamAccountName, Accounttype, NoSmartcardreq, UserMoveDate -Delimiter "," | select SamAccountName -Skip 1
)
$Sam = $CombineSam.SamAccountName

#  if ($sfo -match "aa31421") {Write-Host "ITs a Match"} else {Write-Host No Match}

foreach ($S in $Sam)
{
    if ($S -match $SFOManagedBy)
    {
        Write-Host "$S Matches $SFOName"
    }
    else
    {
        Write-host ""
    }
}

foreach ($s in $sam) {if ($SFO -match "$S") {Write-Host "$SFOManagedBy" -ForegroundColor green} else {Write-Host "No Match" -ForegroundColor Red} }
#>
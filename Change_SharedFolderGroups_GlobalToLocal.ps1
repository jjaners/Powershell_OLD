
# ===  Start Transcript ===
#Start-Transcript -Path "D:\Logs\Global_to_Local_Runonce.txt" -NoClobber

#Get-ADGroup -SearchBase "OU=Storage,OU=ServiceNowGroups,OU=Groups,OU=CoS,DC=ad,DC=stockholm,DC=se" | select -First 10

# So before we begin to process groups, we set a variable to set your searchbase:

$MySearchBase = "OU=Storage,OU=ServiceNowGroups,OU=Groups,OU=CoS,DC=ad,DC=stockholm,DC=se"
# For our first step – we load up a variable with the groups we want (filtered by type):

$MyGroupList = get-adgroup -Filter 'GroupCategory -eq "Security" -and GroupScope -eq "Global"' -SearchBase "$MySearchBase"
#$MyGroupList = get-adgroup -Filter 'GroupCategory -eq "Security" -and GroupScope -eq "DomainLocal" -and Name -like "Test*"' -SearchBase "$MySearchBase"
# -and Name -like "Test*"
# If you want to validate you got the correct groups in the variable, list out the names of your objects in the variable:

$MyGroupList.name
# Now, for every group in the list, we flip the type to Universal:

$MyGroupList | Set-ADGroup -GroupScope Universal
# Now for our second step – we re-load the variable:

$MyGroupList = get-adgroup -Filter 'GroupCategory -eq "Security" -and GroupScope -eq "Universal"' -SearchBase "$MySearchBase"
# -and Name -like "Test*"
# Again, if you want to validate you got the correct groups, list them out:

$MyGroupList.name
# Finally, convert them from Universal to Domain Local:

$MyGroupList | Set-ADGroup -GroupScope DomainLocal
#$MyGroupList | Set-ADGroup -GroupScope Global

# === Stop Transcript ===
#Stop-Transcript

# === Put in Migration mode ===

$cred = Get-Credential
$Pxy = New-WebServiceProxy -Uri "http://ws00970.ad.stockholm.se/HCL.Sthlm.MigrationServices.Service/MigrationServices.svc" -Credential $cred -Namespace WsProxy


#######Put in Migration MODE

$PUTINMIGRATIONMODE = "CODE AT HCL SIDE"

$Pxy.SetBusinessInMigrationMode($PUTINMIGRATIONMODE) 





#Verify org in migration mode

$Migmode=$Pxy.GetBusinessesInMigrationMode()
$Migmode | where isadm -EQ true | select BusinessId,Implemented,Name

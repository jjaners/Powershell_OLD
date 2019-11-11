
#Clear-Variable date
#$Date = get-date yyyyDDmm

$From = "AD.Noreply@tieto.com"
$To = "ext.jack.janers@tieto.com"
$Cc = "jack.janers@gmail.com"
#$Attachment = "D:\Logs\Report\Excel_Reports\Cos_Users_Excel_Report_$Date.xlsx"
$Subject = "Usermigration"
$Body = "Usermigration `n `nRegards `nJack"
#$Body1 = "Hi, Homfolders are ready to go."
#$Body2 = "Kind regards"
#$Body3 = "Jack"
<#
$Body = @"
Hi, Homefolders are good to go.
Kind Regards
Jack
"@
#>
$SMTPServer = "extrelay.stockholm.se"
$SMTPPort = "25"
Send-MailMessage -From $From -to $To -Cc $Cc -Subject $Subject -BodyAsHtml $Body -SmtpServer $SMTPServer -port $SMTPPort -UseSsl


#  -Credential (Get-Credential) –DeliveryNotificationOption OnSuccess -Attachments $Attachment


# All_Attribut_Counter



$AccountExpirationDate = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, AccountExpirationDate -Filter * | Where-Object {$_.AccountExpirationDate -notlike $null} | Measure-Object | select -ExpandProperty count
$AccountLockoutTime = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, AccountLockoutTime -Filter * | Where-Object {$_.AccountLockoutTime -notlike $null} | Measure-Object | select -ExpandProperty count
$AccountNotDelegated = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, AccountNotDelegated -Filter * | Where-Object {$_.AccountNotDelegated -notlike $null} | Measure-Object | select -ExpandProperty count
$AllowReversiblePasswordEncryption = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, AllowReversiblePasswordEncryption -Filter * | Where-Object {$_.AllowReversiblePasswordEncryption -notlike $null} | Measure-Object | select -ExpandProperty count
$AuthenticationPolicy = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, AuthenticationPolicy -Filter * | Where-Object {$_.AuthenticationPolicy -notlike $null} | Measure-Object | select -ExpandProperty count
$AuthenticationPolicySilo = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, AuthenticationPolicySilo -Filter * | Where-Object {$_.AuthenticationPolicySilo -notlike $null} | Measure-Object | select -ExpandProperty count
$BadLogonCount = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, BadLogonCount -Filter * | Where-Object {$_.BadLogonCount -notlike $null} | Measure-Object | select -ExpandProperty count
$CannotChangePassword = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, CannotChangePassword -Filter * | Where-Object {$_.CannotChangePassword -notlike $null} | Measure-Object | select -ExpandProperty count
$CanonicalName = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, CanonicalName -Filter * | Where-Object {$_.CanonicalName -notlike $null} | Measure-Object | select -ExpandProperty count
$Certificates = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, Certificates -Filter * | Where-Object {$_.Certificates -notlike $null} | Measure-Object | select -ExpandProperty count
$City = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, City -Filter * | Where-Object {$_.City -notlike $null} | Measure-Object | select -ExpandProperty count
$CN = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, CN -Filter * | Where-Object {$_.CN -notlike $null} | Measure-Object | select -ExpandProperty count
$codePage = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, codePage -Filter * | Where-Object {$_.codePage -notlike $null} | Measure-Object | select -ExpandProperty count
$CompoundIdentitySupported = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, CompoundIdentitySupported -Filter * | Where-Object {$_.CompoundIdentitySupported -notlike $null} | Measure-Object | select -ExpandProperty count
$Contains = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, Contains -Filter * | Where-Object {$_.Contains -notlike $null} | Measure-Object | select -ExpandProperty count
$Country = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, Country -Filter * | Where-Object {$_.Country -notlike $null} | Measure-Object | select -ExpandProperty count
$countryCode = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, countryCode -Filter * | Where-Object {$_.countryCode -notlike $null} | Measure-Object | select -ExpandProperty count
$Created = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, Created -Filter * | Where-Object {$_.Created -notlike $null} | Measure-Object | select -ExpandProperty count
$createTimeStamp = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, createTimeStamp -Filter * | Where-Object {$_.createTimeStamp -notlike $null} | Measure-Object | select -ExpandProperty count
$Deleted = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, Deleted -Filter * | Where-Object {$_.Deleted -notlike $null} | Measure-Object | select -ExpandProperty count
$Description = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, Description -Filter * | Where-Object {$_.Description -notlike $null} | Measure-Object | select -ExpandProperty count
$DistinguishedName = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, DistinguishedName -Filter * | Where-Object {$_.DistinguishedName -notlike $null} | Measure-Object | select -ExpandProperty count
$DoesNotRequirePreAuth = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, DoesNotRequirePreAuth -Filter * | Where-Object {$_.DoesNotRequirePreAuth -notlike $null} | Measure-Object | select -ExpandProperty count
$dSCorePropagationData = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, dSCorePropagationData -Filter * | Where-Object {$_.dSCorePropagationData -notlike $null} | Measure-Object | select -ExpandProperty count
$EmailAddress = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, EmailAddress -Filter * | Where-Object {$_.EmailAddress -notlike $null} | Measure-Object | select -ExpandProperty count
$EmployeeID = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, EmployeeID -Filter * | Where-Object {$_.EmployeeID -notlike $null} | Measure-Object | select -ExpandProperty count
$Enabled = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, Enabled -Filter * | Where-Object {$_.Enabled -notlike $null} | Measure-Object | select -ExpandProperty count
$Equals = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, Equals -Filter * | Where-Object {$_.Equals -notlike $null} | Measure-Object | select -ExpandProperty count
$extensionAttribute6 = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, extensionAttribute6 -Filter * | Where-Object {$_.extensionAttribute6 -notlike $null} | Measure-Object | select -ExpandProperty count
$Fax = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, Fax -Filter * | Where-Object {$_.Fax -notlike $null} | Measure-Object | select -ExpandProperty count
$GetEnumerator = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, GetEnumerator -Filter * | Where-Object {$_.GetEnumerator -notlike $null} | Measure-Object | select -ExpandProperty count
$GetHashCode = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, GetHashCode -Filter * | Where-Object {$_.GetHashCode -notlike $null} | Measure-Object | select -ExpandProperty count
$GetType = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, GetType -Filter * | Where-Object {$_.GetType -notlike $null} | Measure-Object | select -ExpandProperty count
$HomeDirectory = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, HomeDirectory -Filter * | Where-Object {$_.HomeDirectory -notlike $null} | Measure-Object | select -ExpandProperty count
$HomedirRequired = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, HomedirRequired -Filter * | Where-Object {$_.HomedirRequired -notlike $null} | Measure-Object | select -ExpandProperty count
$HomeDrive = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, HomeDrive -Filter * | Where-Object {$_.HomeDrive -notlike $null} | Measure-Object | select -ExpandProperty count
$homeMDB = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, homeMDB -Filter * | Where-Object {$_.homeMDB -notlike $null} | Measure-Object | select -ExpandProperty count
$HomePage = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, HomePage -Filter * | Where-Object {$_.HomePage -notlike $null} | Measure-Object | select -ExpandProperty count
$HomePhone = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, HomePhone -Filter * | Where-Object {$_.HomePhone -notlike $null} | Measure-Object | select -ExpandProperty count
$Initials = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, Initials -Filter * | Where-Object {$_.Initials -notlike $null} | Measure-Object | select -ExpandProperty count
$instanceType = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, instanceType -Filter * | Where-Object {$_.instanceType -notlike $null} | Measure-Object | select -ExpandProperty count
$isDeleted = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, isDeleted -Filter * | Where-Object {$_.isDeleted -notlike $null} | Measure-Object | select -ExpandProperty count
$Item = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, Item -Filter * | Where-Object {$_.Item -notlike $null} | Measure-Object | select -ExpandProperty count
$KerberosEncryptionType = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, KerberosEncryptionType -Filter * | Where-Object {$_.KerberosEncryptionType -notlike $null} | Measure-Object | select -ExpandProperty count
$LastBadPasswordAttempt = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, LastBadPasswordAttempt -Filter * | Where-Object {$_.LastBadPasswordAttempt -notlike $null} | Measure-Object | select -ExpandProperty count
$LastKnownParent = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, LastKnownParent -Filter * | Where-Object {$_.LastKnownParent -notlike $null} | Measure-Object | select -ExpandProperty count
$LastLogonDate = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, LastLogonDate -Filter * | Where-Object {$_.LastLogonDate -notlike $null} | Measure-Object | select -ExpandProperty count
$lastLogonTimestamp = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, lastLogonTimestamp -Filter * | Where-Object {$_.lastLogonTimestamp -notlike $null} | Measure-Object | select -ExpandProperty count
$legacyExchangeDN = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, legacyExchangeDN -Filter * | Where-Object {$_.legacyExchangeDN -notlike $null} | Measure-Object | select -ExpandProperty count
$LockedOut = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, LockedOut -Filter * | Where-Object {$_.LockedOut -notlike $null} | Measure-Object | select -ExpandProperty count
$lockoutTime = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, lockoutTime -Filter * | Where-Object {$_.lockoutTime -notlike $null} | Measure-Object | select -ExpandProperty count
$LogonWorkstations = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, LogonWorkstations -Filter * | Where-Object {$_.LogonWorkstations -notlike $null} | Measure-Object | select -ExpandProperty count
$managedObjects = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, managedObjects -Filter * | Where-Object {$_.managedObjects -notlike $null} | Measure-Object | select -ExpandProperty count
$mDBOverHardQuotaLimit = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, mDBOverHardQuotaLimit -Filter * | Where-Object {$_.mDBOverHardQuotaLimit -notlike $null} | Measure-Object | select -ExpandProperty count
$mDBOverQuotaLimit = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, mDBOverQuotaLimit -Filter * | Where-Object {$_.mDBOverQuotaLimit -notlike $null} | Measure-Object | select -ExpandProperty count
$mDBStorageQuota = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, mDBStorageQuota -Filter * | Where-Object {$_.mDBStorageQuota -notlike $null} | Measure-Object | select -ExpandProperty count
$mDBUseDefaults = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, mDBUseDefaults -Filter * | Where-Object {$_.mDBUseDefaults -notlike $null} | Measure-Object | select -ExpandProperty count
$MemberOf = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, MemberOf -Filter * | Where-Object {$_.MemberOf -notlike $null} | Measure-Object | select -ExpandProperty count
$MNSLogonAccount = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, MNSLogonAccount -Filter * | Where-Object {$_.MNSLogonAccount -notlike $null} | Measure-Object | select -ExpandProperty count
$MobilePhone = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, MobilePhone -Filter * | Where-Object {$_.MobilePhone -notlike $null} | Measure-Object | select -ExpandProperty count
$Modified = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, Modified -Filter * | Where-Object {$_.Modified -notlike $null} | Measure-Object | select -ExpandProperty count
$modifyTimeStamp = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, modifyTimeStamp -Filter * | Where-Object {$_.modifyTimeStamp -notlike $null} | Measure-Object | select -ExpandProperty count
$msDSUserAccountControlComputed = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, msDS-User-Account-Control-Computed -Filter * | Where-Object {$_.(msDS-User-Account-Control-Computed) -notlike $null} | Measure-Object | select -ExpandProperty count
$msExchELCMailboxFlags = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, msExchELCMailboxFlags -Filter * | Where-Object {$_.msExchELCMailboxFlags -notlike $null} | Measure-Object | select -ExpandProperty count
$msExchHomeServerName = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, msExchHomeServerName -Filter * | Where-Object {$_.msExchHomeServerName -notlike $null} | Measure-Object | select -ExpandProperty count
$msExchMailboxGuid = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, msExchMailboxGuid -Filter * | Where-Object {$_.msExchMailboxGuid -notlike $null} | Measure-Object | select -ExpandProperty count
$msExchMailboxSecurityDescriptor = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, msExchMailboxSecurityDescriptor -Filter * | Where-Object {$_.msExchMailboxSecurityDescriptor -notlike $null} | Measure-Object | select -ExpandProperty count
$msExchMobileMailboxFlags = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, msExchMobileMailboxFlags -Filter * | Where-Object {$_.msExchMobileMailboxFlags -notlike $null} | Measure-Object | select -ExpandProperty count
$msExchOWAPolicy = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, msExchOWAPolicy -Filter * | Where-Object {$_.msExchOWAPolicy -notlike $null} | Measure-Object | select -ExpandProperty count
$msExchPoliciesExcluded = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, msExchPoliciesExcluded -Filter * | Where-Object {$_.msExchPoliciesExcluded -notlike $null} | Measure-Object | select -ExpandProperty count
$msExchRBACPolicyLink = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, msExchRBACPolicyLink -Filter * | Where-Object {$_.msExchRBACPolicyLink -notlike $null} | Measure-Object | select -ExpandProperty count
$msExchRecipientDisplayType = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, msExchRecipientDisplayType -Filter * | Where-Object {$_.msExchRecipientDisplayType -notlike $null} | Measure-Object | select -ExpandProperty count
$msExchRecipientTypeDetails = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, msExchRecipientTypeDetails -Filter * | Where-Object {$_.msExchRecipientTypeDetails -notlike $null} | Measure-Object | select -ExpandProperty count
$msExchSafeSendersHash = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, msExchSafeSendersHash -Filter * | Where-Object {$_.msExchSafeSendersHash -notlike $null} | Measure-Object | select -ExpandProperty count
$msExchTextMessagingState = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, msExchTextMessagingState -Filter * | Where-Object {$_.msExchTextMessagingState -notlike $null} | Measure-Object | select -ExpandProperty count
$msExchUMDtmfMap = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, msExchUMDtmfMap -Filter * | Where-Object {$_.msExchUMDtmfMap -notlike $null} | Measure-Object | select -ExpandProperty count
$msExchUserAccountControl = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, msExchUserAccountControl -Filter * | Where-Object {$_.msExchUserAccountControl -notlike $null} | Measure-Object | select -ExpandProperty count
$msExchUserCulture = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, msExchUserCulture -Filter * | Where-Object {$_.msExchUserCulture -notlike $null} | Measure-Object | select -ExpandProperty count
$msExchVersion = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, msExchVersion -Filter * | Where-Object {$_.msExchVersion -notlike $null} | Measure-Object | select -ExpandProperty count
$msExchWhenMailboxCreated = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, msExchWhenMailboxCreated -Filter * | Where-Object {$_.msExchWhenMailboxCreated -notlike $null} | Measure-Object | select -ExpandProperty count
$msRTCSIPUserRoutingGroupId = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, msRTCSIP-UserRoutingGroupId -Filter * | Where-Object {$_.(msRTCSIP-UserRoutingGroupId) -notlike $null} | Measure-Object | select -ExpandProperty count
$Name = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, Name -Filter * | Where-Object {$_.Name -notlike $null} | Measure-Object | select -ExpandProperty count
$nTSecurityDescriptor = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, nTSecurityDescriptor -Filter * | Where-Object {$_.nTSecurityDescriptor -notlike $null} | Measure-Object | select -ExpandProperty count
$ObjectCategory = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, ObjectCategory -Filter * | Where-Object {$_.ObjectCategory -notlike $null} | Measure-Object | select -ExpandProperty count
$ObjectClass = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, ObjectClass -Filter * | Where-Object {$_.ObjectClass -notlike $null} | Measure-Object | select -ExpandProperty count
$ObjectGUID = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, ObjectGUID -Filter * | Where-Object {$_.ObjectGUID -notlike $null} | Measure-Object | select -ExpandProperty count
$objectSid = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, objectSid -Filter * | Where-Object {$_.objectSid -notlike $null} | Measure-Object | select -ExpandProperty count
$Office = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, Office -Filter * | Where-Object {$_.Office -notlike $null} | Measure-Object | select -ExpandProperty count
$OfficePhone = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, OfficePhone -Filter * | Where-Object {$_.OfficePhone -notlike $null} | Measure-Object | select -ExpandProperty count
$Organization = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, Organization -Filter * | Where-Object {$_.Organization -notlike $null} | Measure-Object | select -ExpandProperty count
$OtherName = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, OtherName -Filter * | Where-Object {$_.OtherName -notlike $null} | Measure-Object | select -ExpandProperty count
$PasswordExpired = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, PasswordExpired -Filter * | Where-Object {$_.PasswordExpired -notlike $null} | Measure-Object | select -ExpandProperty count
$PasswordLastSet = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, PasswordLastSet -Filter * | Where-Object {$_.PasswordLastSet -notlike $null} | Measure-Object | select -ExpandProperty count
$PasswordNeverExpires = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, PasswordNeverExpires -Filter * | Where-Object {$_.PasswordNeverExpires -notlike $null} | Measure-Object | select -ExpandProperty count
$PasswordNotRequired = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, PasswordNotRequired -Filter * | Where-Object {$_.PasswordNotRequired -notlike $null} | Measure-Object | select -ExpandProperty count
$POBox = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, POBox -Filter * | Where-Object {$_.POBox -notlike $null} | Measure-Object | select -ExpandProperty count
$PrimaryGroup = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, PrimaryGroup -Filter * | Where-Object {$_.PrimaryGroup -notlike $null} | Measure-Object | select -ExpandProperty count
$primaryGroupID = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, primaryGroupID -Filter * | Where-Object {$_.primaryGroupID -notlike $null} | Measure-Object | select -ExpandProperty count
$PrincipalsAllowedToDelegateToAccount = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, PrincipalsAllowedToDelegateToAccount -Filter * | Where-Object {$_.PrincipalsAllowedToDelegateToAccount -notlike $null} | Measure-Object | select -ExpandProperty count
$ProfilePath = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, ProfilePath -Filter * | Where-Object {$_.ProfilePath -notlike $null} | Measure-Object | select -ExpandProperty count
$ProtectedFromAccidentalDeletion = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, ProtectedFromAccidentalDeletion -Filter * | Where-Object {$_.ProtectedFromAccidentalDeletion -notlike $null} | Measure-Object | select -ExpandProperty count
$protocolSettings = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, protocolSettings -Filter * | Where-Object {$_.protocolSettings -notlike $null} | Measure-Object | select -ExpandProperty count
$pwdLastSet = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, pwdLastSet -Filter * | Where-Object {$_.pwdLastSet -notlike $null} | Measure-Object | select -ExpandProperty count
$sAMAccountType = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, sAMAccountType -Filter * | Where-Object {$_.sAMAccountType -notlike $null} | Measure-Object | select -ExpandProperty count
$ScriptPath = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, ScriptPath -Filter * | Where-Object {$_.ScriptPath -notlike $null} | Measure-Object | select -ExpandProperty count
$sDRightsEffective = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, sDRightsEffective -Filter * | Where-Object {$_.sDRightsEffective -notlike $null} | Measure-Object | select -ExpandProperty count
$ServicePrincipalNames = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, ServicePrincipalNames -Filter * | Where-Object {$_.ServicePrincipalNames -notlike $null} | Measure-Object | select -ExpandProperty count
$showInAddressBook = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, showInAddressBook -Filter * | Where-Object {$_.showInAddressBook -notlike $null} | Measure-Object | select -ExpandProperty count
$SID = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, SID -Filter * | Where-Object {$_.SID -notlike $null} | Measure-Object | select -ExpandProperty count
$SIDHistory = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, SIDHistory -Filter * | Where-Object {$_.SIDHistory -notlike $null} | Measure-Object | select -ExpandProperty count
$SmartcardLogonRequired = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, SmartcardLogonRequired -Filter * | Where-Object {$_.SmartcardLogonRequired -notlike $null} | Measure-Object | select -ExpandProperty count
$State = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, State -Filter * | Where-Object {$_.State -notlike $null} | Measure-Object | select -ExpandProperty count
$submissionContLength = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, submissionContLength -Filter * | Where-Object {$_.submissionContLength -notlike $null} | Measure-Object | select -ExpandProperty count
$Surname = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, Surname -Filter * | Where-Object {$_.Surname -notlike $null} | Measure-Object | select -ExpandProperty count
$ToString = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, ToString -Filter * | Where-Object {$_.ToString -notlike $null} | Measure-Object | select -ExpandProperty count
$TrustedForDelegation = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, TrustedForDelegation -Filter * | Where-Object {$_.TrustedForDelegation -notlike $null} | Measure-Object | select -ExpandProperty count
$TrustedToAuthForDelegation = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, TrustedToAuthForDelegation -Filter * | Where-Object {$_.TrustedToAuthForDelegation -notlike $null} | Measure-Object | select -ExpandProperty count
$UseDESKeyOnly = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, UseDESKeyOnly -Filter * | Where-Object {$_.UseDESKeyOnly -notlike $null} | Measure-Object | select -ExpandProperty count
$userCertificate = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, userCertificate -Filter * | Where-Object {$_.userCertificate -notlike $null} | Measure-Object | select -ExpandProperty count
$uSNChanged = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, uSNChanged -Filter * | Where-Object {$_.uSNChanged -notlike $null} | Measure-Object | select -ExpandProperty count
$uSNCreated = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, uSNCreated -Filter * | Where-Object {$_.uSNCreated -notlike $null} | Measure-Object | select -ExpandProperty count
$whenChanged = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, whenChanged -Filter * | Where-Object {$_.whenChanged -notlike $null} | Measure-Object | select -ExpandProperty count
$whenCreated = Get-aduser -SearchBase 'OU=Users,OU=STHLM,DC=ad,DC=stockholm,DC=se' -properties name, whenCreated -Filter * | Where-Object {$_.whenCreated -notlike $null} | Measure-Object | select -ExpandProperty count


$info = @{
'AccountExpirationDate' = $AccountExpirationDate;
'AccountLockoutTime' = $AccountLockoutTime;
'AccountNotDelegated' = $AccountNotDelegated;
'AllowReversiblePasswordEncryption' = $AllowReversiblePasswordEncryption;
'AuthenticationPolicy' = $AuthenticationPolicy;
'AuthenticationPolicySilo' = $AuthenticationPolicySilo;
'BadLogonCount' = $BadLogonCount;
'CannotChangePassword' = $CannotChangePassword;
'CanonicalName' = $CanonicalName;
'Certificates' = $Certificates;
'City' = $City;
'CN' = $CN;
'codePage' = $codePage;
'CompoundIdentitySupported' = $CompoundIdentitySupported;
'Contains' = $Contains;
'Country' = $Country;
'countryCode' = $countryCode;
'Created' = $Created;
'createTimeStamp' = $createTimeStamp;
'Deleted' = $Deleted;
'Description' = $Description;
'DistinguishedName' = $DistinguishedName;
'DoesNotRequirePreAuth' = $DoesNotRequirePreAuth;
'dSCorePropagationData' = $dSCorePropagationData;
'EmailAddress' = $EmailAddress;
'EmployeeID' = $EmployeeID;
'Enabled' = $Enabled;
'Equals' = $Equals;
'extensionAttribute6' = $extensionAttribute6;
'Fax' = $Fax;
'GetEnumerator' = $GetEnumerator;
'GetHashCode' = $GetHashCode;
'GetType' = $GetType;
'HomeDirectory' = $HomeDirectory;
'HomedirRequired' = $HomedirRequired;
'HomeDrive' = $HomeDrive;
'homeMDB' = $homeMDB;
'HomePage' = $HomePage;
'HomePhone' = $HomePhone;
'Initials' = $Initials;
'instanceType' = $instanceType;
'isDeleted' = $isDeleted;
'Item' = $Item;
'KerberosEncryptionType' = $KerberosEncryptionType;
'LastBadPasswordAttempt' = $LastBadPasswordAttempt;
'LastKnownParent' = $LastKnownParent;
'LastLogonDate' = $LastLogonDate;
'lastLogonTimestamp' = $lastLogonTimestamp;
'legacyExchangeDN' = $legacyExchangeDN;
'LockedOut' = $LockedOut;
'lockoutTime' = $lockoutTime;
'LogonWorkstations' = $LogonWorkstations;
'managedObjects' = $managedObjects;
'mDBOverHardQuotaLimit' = $mDBOverHardQuotaLimit;
'mDBOverQuotaLimit' = $mDBOverQuotaLimit;
'mDBStorageQuota' = $mDBStorageQuota;
'mDBUseDefaults' = $mDBUseDefaults;
'MemberOf' = $MemberOf;
'MNSLogonAccount' = $MNSLogonAccount;
'MobilePhone' = $MobilePhone;
'Modified' = $Modified;
'modifyTimeStamp' = $modifyTimeStamp;
'msDS-User-Account-Control-Computed' = $msDSUserAccountControlComputed;
'msExchELCMailboxFlags' = $msExchELCMailboxFlags;
'msExchHomeServerName' = $msExchHomeServerName;
'msExchMailboxGuid' = $msExchMailboxGuid;
'msExchMailboxSecurityDescriptor' = $msExchMailboxSecurityDescriptor;
'msExchMobileMailboxFlags' = $msExchMobileMailboxFlags;
'msExchOWAPolicy' = $msExchOWAPolicy;
'msExchPoliciesExcluded' = $msExchPoliciesExcluded;
'msExchRBACPolicyLink' = $msExchRBACPolicyLink;
'msExchRecipientDisplayType' = $msExchRecipientDisplayType;
'msExchRecipientTypeDetails' = $msExchRecipientTypeDetails;
'msExchSafeSendersHash' = $msExchSafeSendersHash;
'msExchTextMessagingState' = $msExchTextMessagingState;
'msExchUMDtmfMap' = $msExchUMDtmfMap;
'msExchUserAccountControl' = $msExchUserAccountControl;
'msExchUserCulture' = $msExchUserCulture;
'msExchVersion' = $msExchVersion;
'msExchWhenMailboxCreated' = $msExchWhenMailboxCreated;
'msRTCSIP-UserRoutingGroupId' = $msRTCSIPUserRoutingGroupId;
'Name' = $Name;
'nTSecurityDescriptor' = $nTSecurityDescriptor;
'ObjectCategory' = $ObjectCategory;
'ObjectClass' = $ObjectClass;
'ObjectGUID' = $ObjectGUID;
'objectSid' = $objectSid;
'Office' = $Office;
'OfficePhone' = $OfficePhone;
'Organization' = $Organization;
'OtherName' = $OtherName;
'PasswordExpired' = $PasswordExpired;
'PasswordLastSet' = $PasswordLastSet;
'PasswordNeverExpires' = $PasswordNeverExpires;
'PasswordNotRequired' = $PasswordNotRequired;
'POBox' = $POBox;
'PrimaryGroup' = $PrimaryGroup;
'primaryGroupID' = $primaryGroupID;
'PrincipalsAllowedToDelegateToAccount' = $PrincipalsAllowedToDelegateToAccount;
'ProfilePath' = $ProfilePath;
'ProtectedFromAccidentalDeletion' = $ProtectedFromAccidentalDeletion;
'protocolSettings' = $protocolSettings;
'pwdLastSet' = $pwdLastSet;
'sAMAccountType' = $sAMAccountType;
'ScriptPath' = $ScriptPath;
'sDRightsEffective' = $sDRightsEffective;
'ServicePrincipalNames' = $ServicePrincipalNames;
'showInAddressBook' = $showInAddressBook;
'SID' = $SID;
'SIDHistory' = $SIDHistory;
'SmartcardLogonRequired' = $SmartcardLogonRequired;
'State' = $State;
'submissionContLength' = $submissionContLength;
'Surname' = $Surname;
'ToString' = $ToString;
'TrustedForDelegation' = $TrustedForDelegation;
'TrustedToAuthForDelegation' = $TrustedToAuthForDelegation;
'UseDESKeyOnly' = $UseDESKeyOnly;
'userCertificate' = $userCertificate;
'uSNChanged' = $uSNChanged;
'uSNCreated' = $uSNCreated;
'whenChanged' = $whenChanged;
'whenCreated' = $whenCreated;

 }
$info | out-file C:\Powershell\PS_Results\all_Attribute_Counter_Result.txt
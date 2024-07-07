Import-Module 'C:\Program Files\Microsoft Dynamics 365 Business Central\240\Service\NavAdminTool.ps1'


#New-Certificate
New-SelfSignedCertificate -DnsName DESKTOP-AHDAD64 -FriendlyName BC24Pass -KeyUsage DigitalSignature
#FOR NEW USER:
#New-NAVServerUser -ServerInstance BC140 -WindowsAccount DESKTOP-AHDAD64\Administrator
New-NAVServerUser -ServerInstance BC240 -UserName Lokesh -AuthenticationEmail luckysharmasharma336@gmail.com -FullName "Lokesh Sharma" -Password (Read-Host "Enter Password" -AsSecureString) -Tenant default
New-NAVServerUserPermissionSet -PermissionSetId SUPER -ServerInstance BC240 -UserName Lokesh

#Update Service Parameter
Set-NAVServerConfiguration -KeyName ClientServicesCredentialType -ServerInstance BC240 -KeyValue "NavUserPassword"
Set-NAVServerConfiguration -KeyName ServicesCertificateThumbprint -ServerInstance BC240 -KeyValue "DB76E608A3F54512CB9A623AAC1570F8B64656F8"
Set-NAVServerConfiguration -KeyName ClientServicesSSLEnabled -ServerInstance BC240 -KeyValue true
Restart-NAVServerInstance -ServerInstance BC240


#Update the web service client Parameters
Set-NAVWebServerInstanceConfiguration -KeyName ClientServicesCredentialType -KeyValue NavUserPassword -WebServerInstance BC240
Set-NAVWebServerInstanceConfiguration -KeyName Serverhttps -KeyValue true -WebServerInstance BC240
Set-NAVWebServerInstanceConfiguration -KeyName DnsIdentity -KeyValue DESKTOP-AHDAD64 -WebServerInstance BC240
Set-NAVWebServerInstanceConfiguration -KeyName RequireSSL -KeyValue true -WebServerInstance BC240
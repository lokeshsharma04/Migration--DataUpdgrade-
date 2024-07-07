########################################################################
#Author : Saurav Dhyani
#Date   : 12-07-2023
#Purpose: Execute Step 2 of BC14 to BC22 Upgrade
########################################################################

#Execute this cmd in Sql Server Management Studio
UPDATE [master].[dbo].[$ndo$srvproperty] SET [license] = null
UPDATE [NISSINBCUAT].[dbo].[$ndo$dbproperty] SET [license] = null
UPDATE [NISSINBCUAT].[dbo].[$ndo$tenantproperty] SET [license] = null

#Import Module
Import-Module 'C:\Program Files\Microsoft Dynamics 365 Business Central\220\Service\NavAdminTool.ps1'



#Convert the application database to version 22
Invoke-NAVApplicationDatabaseConversion -DatabaseServer localhost\BCDEMO14 -DatabaseName "NISSINBCUAT"




#Configure version 22 server for DestinationAppsForMigration
Set-NAVServerConfiguration -ServerInstance BC220 -KeyName DatabaseServer -KeyValue localhost
Set-NAVServerConfiguration -ServerInstance BC220 -KeyName DatabaseInstance -KeyValue "BCDEMO14"
Set-NAVServerConfiguration -ServerInstance BC220 -KeyName DatabaseName -KeyValue "NISSINBCUAT"

Set-NAVServerConfiguration -ServerInstance BC220 -KeyName "DestinationAppsForMigration" -KeyValue '[{"appId":"63ca2fa4-4f03-4f2b-a480-172fef340d3f", "name":"System Application", "publisher": "Microsoft"},{"appId":"437dbf0e-84ff-417a-965d-ed2bb9650972", "name":"Base Application", "publisher": "Microsoft"}]'
Set-NavServerConfiguration -ServerInstance BC220 -KeyName "EnableTaskScheduler" -KeyValue false
Restart-NAVServerInstance -ServerInstance BC220

Import-NAVServerLicense -ServerInstance BC220 -LicenseFile "D:\4805044 - BC 22.bclicense"
Restart-NAVServerInstance -ServerInstance BC220

#Publish extensions
Publish-NAVApp -ServerInstance BC220 -Path "D:\Migration Task\BC Apps 22\Microsoft_System Application.app"
Publish-NAVApp -ServerInstance BC220 -Path "D:\Migration Task\BC Apps 22\Microsoft_Base Application.app"
Publish-NAVApp -ServerInstance BC220 -Path "D:\Migration Task\BC Apps 22\Microsoft_Application.app"
Publish-NAVApp -ServerInstance BC220 -Path "D:\Migration Task\NISSIN TASK\customapp\Tectura_Custom_22.0.0.0.app" -SkipVerification

#Restart service
Restart-NAVServerInstance -ServerInstance BC220

#Synchronize tenant
Sync-NAVTenant -ServerInstance BC220 -Tenant default -Mode Sync

#Synchronize Apps
Sync-NAVApp -ServerInstance BC220 -Tenant default -Name "System Application" -Version 22.0.54157.55195
Sync-NAVApp -ServerInstance BC220 -Tenant default -Name "Base Application" -Version 22.0.54157.55195
Sync-NAVApp -ServerInstance BC220 -Tenant default -Name "Application" -Version 22.0.54157.55195
Sync-NAVApp -ServerInstance BC220 -Tenant default -Name "Custom" -Version 22.0.0.0

#Upgrade data
Start-NAVDataUpgrade -ServerInstance BC220 -Tenant default -FunctionExecutionMode Serial -SkipAppVersionCheck

#Install Apps
Install-NAVApp -ServerInstance BC220 -Tenant default -Name "Application" -Version 22.0.54157.55195

#Upgrade Apps / Extension
Start-NAVAppDataUpgrade -ServerInstance BC220 -Name "Custom" -Version 22.0.0.0

#Upgrade control add-ins
$AddinsFolder = 'C:\Program Files\Microsoft Dynamics 365 Business Central\220\Service\Add-ins'

Set-NAVAddIn -ServerInstance BC220 -AddinName 'Microsoft.Dynamics.Nav.Client.BusinessChart' -PublicKeyToken 31bf3856ad364e35 -ResourceFile ($AppName = Join-Path $AddinsFolder 'BusinessChart\Microsoft.Dynamics.Nav.Client.BusinessChart.zip')
Set-NAVAddIn -ServerInstance BC220 -AddinName 'Microsoft.Dynamics.Nav.Client.FlowIntegration' -PublicKeyToken 31bf3856ad364e35 -ResourceFile ($AppName = Join-Path $AddinsFolder 'FlowIntegration\Microsoft.Dynamics.Nav.Client.FlowIntegration.zip')
Set-NAVAddIn -ServerInstance BC220 -AddinName 'Microsoft.Dynamics.Nav.Client.OAuthIntegration' -PublicKeyToken 31bf3856ad364e35 -ResourceFile ($AppName = Join-Path $AddinsFolder 'OAuthIntegration\Microsoft.Dynamics.Nav.Client.OAuthIntegration.zip')
Set-NAVAddIn -ServerInstance BC220 -AddinName 'Microsoft.Dynamics.Nav.Client.PageReady' -PublicKeyToken 31bf3856ad364e35 -ResourceFile ($AppName = Join-Path $AddinsFolder 'PageReady\Microsoft.Dynamics.Nav.Client.PageReady.zip')
Set-NAVAddIn -ServerInstance BC220 -AddinName 'Microsoft.Dynamics.Nav.Client.PowerBIManagement' -PublicKeyToken 31bf3856ad364e35 -ResourceFile ($AppName = Join-Path $AddinsFolder 'PowerBIManagement\Microsoft.Dynamics.Nav.Client.PowerBIManagement.zip')
Set-NAVAddIn -ServerInstance BC220 -AddinName 'Microsoft.Dynamics.Nav.Client.RoleCenterSelector' -PublicKeyToken 31bf3856ad364e35 -ResourceFile ($AppName = Join-Path $AddinsFolder 'RoleCenterSelector\Microsoft.Dynamics.Nav.Client.RoleCenterSelector.zip')
Set-NAVAddIn -ServerInstance BC220 -AddinName 'Microsoft.Dynamics.Nav.Client.SatisfactionSurvey' -PublicKeyToken 31bf3856ad364e35 -ResourceFile ($AppName = Join-Path $AddinsFolder 'SatisfactionSurvey\Microsoft.Dynamics.Nav.Client.SatisfactionSurvey.zip')
Set-NAVAddIn -ServerInstance BC220 -AddinName 'Microsoft.Dynamics.Nav.Client.SocialListening' -PublicKeyToken 31bf3856ad364e35 -ResourceFile ($AppName = Join-Path $AddinsFolder 'SocialListening\Microsoft.Dynamics.Nav.Client.SocialListening.zip')
Set-NAVAddIn -ServerInstance BC220 -AddinName 'Microsoft.Dynamics.Nav.Client.VideoPlayer' -PublicKeyToken 31bf3856ad364e35 -ResourceFile ($AppName = Join-Path $AddinsFolder 'VideoPlayer\Microsoft.Dynamics.Nav.Client.VideoPlayer.zip')
Set-NAVAddIn -ServerInstance BC220 -AddinName 'Microsoft.Dynamics.Nav.Client.WebPageViewer' -PublicKeyToken 31bf3856ad364e35 -ResourceFile ($AppName = Join-Path $AddinsFolder 'WebPageViewer\Microsoft.Dynamics.Nav.Client.WebPageViewer.zip')
Set-NAVAddIn -ServerInstance BC220 -AddinName 'Microsoft.Dynamics.Nav.Client.WelcomeWizard' -PublicKeyToken 31bf3856ad364e35 -ResourceFile ($AppName = Join-Path $AddinsFolder 'WelcomeWizard\Microsoft.Dynamics.Nav.Client.WelcomeWizard.zip')

#Change application version
Set-NAVApplication -ServerInstance BC220 -ApplicationVersion 22.0.54157.55195 -Force
Sync-NAVTenant -ServerInstance BC220 -Mode Sync -Tenant default
Start-NAVDataUpgrade -ServerInstance BC220 -FunctionExecutionMode Serial -Tenant default -SkipUserSessionCheck
Set-NAVServerConfiguration -ServerInstance BC220 -KeyName SolutionVersionExtension -KeyValue "437dbf0e-84ff-417a-965d-ed2bb9650972" -ApplyTo All  
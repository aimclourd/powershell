<#
    .SYNOPSIS
    Module d'intéraction avec WSUS
    
    .DESCRIPTION
    Ce module regroupe toutes les fonctions supplémentaires d'intéraction avec WSUS.	
	
    .LINK
     
    .NOTE
    Auteur: Grégory DAVID (gregory.david@sncf.fr)       
#>

function recuperer_parametrage_wsus
	{
	param($nom_machine)
	if (!(Get-Module -Name registre))
		{
		Import-Module -Name registre
		}
	#Write-Output "machine $nom_machine"
	if (Test-Connection $nom_machine -Count 1 -ErrorAction:SilentlyContinue)
		{	
		$infos_os = recuperer_infos_os -nom_machine $nom_machine
		$global:archi_os = $infos_os.Architecture	
		$toutes_infos_configuration_wsus = @()
		$objconfiguration_wsus = New-Object Psobject	
		if ($global:archi_os -like "64*")
			{			
			$valeur_cle_targetgroupenabled = lire_valeurdword_cle_registre -chemin "SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate" -cle TargetGroupEnabled -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_targetgroup = lire_valeurstring_cle_registre -chemin "SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate" -cle TargetGroup -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_DoNotConnectToWindowsUpdateInternetLocations = lire_valeurdword_cle_registre -chemin "SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate" -cle DoNotConnectToWindowsUpdateInternetLocations -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_DisableWindowsUpdateAccess = lire_valeurdword_cle_registre -chemin "SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate" -cle DisableWindowsUpdateAccess -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_wuserver = lire_valeurstring_cle_registre -chemin "SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate" -cle WUServer -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_wustatusserver = lire_valeurstring_cle_registre -chemin "SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate" -cle WUStatusServer -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_auoptions = lire_valeurdword_cle_registre -chemin "SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle AUOptions -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_scheduledinstallday = lire_valeurdword_cle_registre -chemin "SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle ScheduledInstallDay -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_scheduledinstalltime = lire_valeurdword_cle_registre -chemin "SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle ScheduledInstallTime -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_usewuserver = lire_valeurdword_cle_registre -chemin "SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle usewuserver -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_AlwaysAutoRebootAtScheduledTime = lire_valeurdword_cle_registre -chemin "SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle AlwaysAutoRebootAtScheduledTime -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_NoAutoUpdate = lire_valeurdword_cle_registre -chemin "SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle NoAutoUpdate -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_DetectionFrequencyEnabled = lire_valeurdword_cle_registre -chemin "SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle DetectionFrequencyEnabled -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_NoAUShutdownOption = lire_valeurdword_cle_registre -chemin "SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle NoAUShutdownOption -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_AutoInstallMinorUpdates = lire_valeurdword_cle_registre -chemin "SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle AutoInstallMinorUpdates -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_NoAUAsDefaultShutdownOption = lire_valeurdword_cle_registre -chemin "SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle NoAUAsDefaultShutdownOption -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_RescheduleWaitTimeEnabled = lire_valeurdword_cle_registre -chemin "SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle RescheduleWaitTimeEnabled -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_RescheduleWaitTime = lire_valeurdword_cle_registre -chemin "SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle RescheduleWaitTime -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_NoAutoRebootWithLoggedOnUsers = lire_valeurdword_cle_registre -chemin "SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle NoAutoRebootWithLoggedOnUsers -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_DetectionFrequency = lire_valeurdword_cle_registre -chemin "SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle DetectionFrequency -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_RebootWarningTimeoutEnabled = lire_valeurdword_cle_registre -chemin "SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle RebootWarningTimeoutEnabled -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_RebootRelaunchTimeoutEnabled = lire_valeurdword_cle_registre -chemin "SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle RebootRelaunchTimeoutEnabled -nom_machine $nom_machine -ruche "HKLM"				
			}
		else
			{			
			$valeur_cle_targetgroupenabled = lire_valeurdword_cle_registre -chemin "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -cle TargetGroupEnabled -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_targetgroup = lire_valeurstring_cle_registre -chemin "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -cle TargetGroup -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_DoNotConnectToWindowsUpdateInternetLocations = lire_valeurdword_cle_registre -chemin "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -cle DoNotConnectToWindowsUpdateInternetLocations -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_DisableWindowsUpdateAccess = lire_valeurdword_cle_registre -chemin "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -cle DisableWindowsUpdateAccess -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_wuserver = lire_valeurstring_cle_registre -chemin "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -cle WUServer -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_wustatusserver = lire_valeurstring_cle_registre -chemin "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -cle WUStatusServer -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_auoptions = lire_valeurdword_cle_registre -chemin "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle AUOptions -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_scheduledinstallday = lire_valeurdword_cle_registre -chemin "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle ScheduledInstallDay -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_scheduledinstalltime = lire_valeurdword_cle_registre -chemin "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle ScheduledInstallTime -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_usewuserver = lire_valeurdword_cle_registre -chemin "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle usewuserver -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_AlwaysAutoRebootAtScheduledTime = lire_valeurdword_cle_registre -chemin "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle AlwaysAutoRebootAtScheduledTime -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_NoAutoUpdate = lire_valeurdword_cle_registre -chemin "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle NoAutoUpdate -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_DetectionFrequencyEnabled = lire_valeurdword_cle_registre -chemin "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle DetectionFrequencyEnabled -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_NoAUShutdownOption = lire_valeurdword_cle_registre -chemin "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle NoAUShutdownOption -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_AutoInstallMinorUpdates = lire_valeurdword_cle_registre -chemin "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle AutoInstallMinorUpdates -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_NoAUAsDefaultShutdownOption = lire_valeurdword_cle_registre -chemin "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle NoAUAsDefaultShutdownOption -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_RescheduleWaitTimeEnabled = lire_valeurdword_cle_registre -chemin "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle RescheduleWaitTimeEnabled -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_RescheduleWaitTime = lire_valeurdword_cle_registre -chemin "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle RescheduleWaitTime -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_NoAutoRebootWithLoggedOnUsers = lire_valeurdword_cle_registre -chemin "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle NoAutoRebootWithLoggedOnUsers -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_DetectionFrequency = lire_valeurdword_cle_registre -chemin "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle DetectionFrequency -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_RebootWarningTimeoutEnabled = lire_valeurdword_cle_registre -chemin "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle RebootWarningTimeoutEnabled -nom_machine $nom_machine -ruche "HKLM"
			$valeur_cle_RebootRelaunchTimeoutEnabled = lire_valeurdword_cle_registre -chemin "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle RebootRelaunchTimeoutEnabled -nom_machine $nom_machine -ruche "HKLM"			
			}
			$objconfiguration_wsus | Add-Member -Name "TargetGroupEnabled" -MemberType NoteProperty -Value $valeur_cle_targetgroupenabled 
			$objconfiguration_wsus | Add-Member -Name "TargetGroup" -MemberType NoteProperty -Value $valeur_cle_targetgroup 
			$objconfiguration_wsus | Add-Member -Name "DoNotConnectToWindowsUpdateInternetLocations" -MemberType NoteProperty -Value $valeur_cle_DoNotConnectToWindowsUpdateInternetLocations 
			$objconfiguration_wsus | Add-Member -Name "DisableWindowsUpdateAccess" -MemberType NoteProperty -Value $valeur_cle_DisableWindowsUpdateAccess 
			$objconfiguration_wsus | Add-Member -Name "WUServer" -MemberType NoteProperty -Value $valeur_cle_wuserver 
			$objconfiguration_wsus | Add-Member -Name "WUStatusServer" -MemberType NoteProperty -Value $valeur_cle_wustatusserver 
			$objconfiguration_wsus | Add-Member -Name "AUOptions" -MemberType NoteProperty -Value $valeur_cle_auoptions 
			$objconfiguration_wsus | Add-Member -Name "ScheduledInstallDay" -MemberType NoteProperty -Value $valeur_cle_scheduledinstallday 
			$objconfiguration_wsus | Add-Member -Name "ScheduledInstallTime" -MemberType NoteProperty -Value $valeur_cle_scheduledinstalltime 
			$objconfiguration_wsus | Add-Member -Name "UseWUServer" -MemberType NoteProperty -Value $valeur_cle_usewuserver 
			$objconfiguration_wsus | Add-Member -Name "AlwaysAutoRebootAtScheduledTime" -MemberType NoteProperty -Value $valeur_cle_AlwaysAutoRebootAtScheduledTime 
			$objconfiguration_wsus | Add-Member -Name "NoAutoUpdate" -MemberType NoteProperty -Value $valeur_cle_NoAutoUpdate 
			$objconfiguration_wsus | Add-Member -Name "DetectionFrequencyEnabled" -MemberType NoteProperty -Value $valeur_cle_DetectionFrequencyEnabled 
			$objconfiguration_wsus | Add-Member -Name "NoAUShutdownOption" -MemberType NoteProperty -Value $valeur_cle_NoAUShutdownOption 
			$objconfiguration_wsus | Add-Member -Name "AutoInstallMinorUpdates" -MemberType NoteProperty -Value $valeur_cle_AutoInstallMinorUpdates 
			$objconfiguration_wsus | Add-Member -Name "NoAUAsDefaultShutdownOption" -MemberType NoteProperty -Value $valeur_cle_NoAUAsDefaultShutdownOption 
			$objconfiguration_wsus | Add-Member -Name "RescheduleWaitTimeEnabled" -MemberType NoteProperty -Value $valeur_cle_RescheduleWaitTimeEnabled 
			$objconfiguration_wsus | Add-Member -Name "RescheduleWaitTime" -MemberType NoteProperty -Value $valeur_cle_RescheduleWaitTime 
			$objconfiguration_wsus | Add-Member -Name "NoAutoRebootWithLoggedOnUsers" -MemberType NoteProperty -Value $valeur_cle_NoAutoRebootWithLoggedOnUsers 
			$objconfiguration_wsus | Add-Member -Name "DetectionFrequency" -MemberType NoteProperty -Value $valeur_cle_DetectionFrequency 
			$objconfiguration_wsus | Add-Member -Name "RebootWarningTimeoutEnabled" -MemberType NoteProperty -Value $valeur_cle_RebootWarningTimeoutEnabled 
			$objconfiguration_wsus | Add-Member -Name "RebootRelaunchTimeoutEnabled" -MemberType NoteProperty -Value $valeur_cle_RebootRelaunchTimeoutEnabled 
			$toutes_infos_configuration_wsus += $objconfiguration_wsus
			Write-Output $toutes_infos_configuration_wsus
		}
	}
	
function configurer_wsus
	{
	param($nom_machine,
	$heure_wsus,
	$jour_wsus,
	$perimetre)
		if (!(Get-Module -Name registre))
		{
		Import-Module -Name registre
		}
	if ($perimetre -eq "horsprod")
		{
		$valeur_targetgroup = "mytargetgroup"
		$valeur_WUStatusServer = "mywsusserver"
		$valeur_WUServer = "mywsusserver"
		}
	if ($perimetre -eq "prod")
		{
		$valeur_targetgroup = "mytargetgroup"
		$valeur_WUStatusServer = "mywsusserver"
		$valeur_WUServer = "mywsusserver"
		}
	if (Test-Connection $nom_machine -Count 4 -ErrorAction:SilentlyContinue)
		{
		}
		else
		{
		
		Write-Host "Configuration du serveur $nom_machine"
		$date = Get-Date -Format "dd/MM/yyyy hh:mm:ss"
		if ($global:archi_os -like "64*")
			{
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate" -cle "TargetGroupEnabled" -valeur "00000001"
			ecrire_valeurstring_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate" -cle "TargetGroup" -valeur $valeur_targetgroup
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate" -cle "DoNotConnectToWindowsUpdateInternetLocations" -valeur "00000001"
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate" -cle "DisableWindowsUpdateAccess" -valeur "00000001"
			ecrire_valeurstring_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate" -cle "WUStatusServer" -valeur $valeur_WUStatusServer
			ecrire_valeurstring_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate" -cle "WUServer" -valeur $valeur_WUStatusServer
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle "AUOptions" -valeur "00000004"
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle "ScheduledInstallDay" -valeur $valeur_jour_wsus
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle "ScheduledInstallTime" -valeur $valeur_heure_wsus
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle "AlwaysAutoRebootAtScheduledTime" -valeur "00000001"
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle "UseWUServer" -valeur "00000001"
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle "NoAutoUpdate" -valeur "00000000"
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle "DetectionFrequencyEnabled" -valeur "00000001"
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle "NoAUShutdownOption" -valeur "00000001"
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle "AutoInstallMinorUpdates" -valeur "00000001"
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle "NoAUAsDefaultShutdownOption" -valeur "00000000"
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle "RescheduleWaitTimeEnabled" -valeur "00000001"
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle "RescheduleWaitTime" -valeur "30"
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle "NoAutoRebootWithLoggedOnUsers" -valeur "00000000"
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle "DetectionFrequency" -valeur "00000006"
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle "RebootWarningTimeoutEnabled" -valeur "00000000"
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle "RebootRelaunchTimeoutEnabled" -valeur "00000000"
			}
		else
			{				
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Policies\Microsoft\Windows\WindowsUpdate" -cle "TargetGroupEnabled" -valeur "00000001"
			ecrire_valeurstring_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Policies\Microsoft\Windows\WindowsUpdate" -cle "TargetGroup" -valeur $valeur_targetgroup
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Policies\Microsoft\Windows\WindowsUpdate" -cle "DoNotConnectToWindowsUpdateInternetLocations" -valeur "00000001"
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Policies\Microsoft\Windows\WindowsUpdate" -cle "DisableWindowsUpdateAccess" -valeur "00000001"
			ecrire_valeurstring_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Policies\Microsoft\Windows\WindowsUpdate" -cle "WUStatusServer" -valeur $valeur_WUStatusServer
			ecrire_valeurstring_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Policies\Microsoft\Windows\WindowsUpdate" -cle "WUServer" -valeur $valeur_WUStatusServer
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle "AUOptions" -valeur "00000004"
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle "ScheduledInstallDay" -valeur $valeur_jour_wsus
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle "ScheduledInstallTime" -valeur $valeur_heure_wsus
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle "AlwaysAutoRebootAtScheduledTime" -valeur "00000001"
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle "UseWUServer" -valeur "00000001"
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle "NoAutoUpdate" -valeur "00000000"
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle "DetectionFrequencyEnabled" -valeur "00000001"
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle "NoAUShutdownOption" -valeur "00000001"
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle "AutoInstallMinorUpdates" -valeur "00000001"
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle "NoAUAsDefaultShutdownOption" -valeur "00000000"
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle "RescheduleWaitTimeEnabled" -valeur "00000001"
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle "RescheduleWaitTime" -valeur "30"
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle "NoAutoRebootWithLoggedOnUsers" -valeur "00000000"
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle "DetectionFrequency" -valeur "00000006"
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle "RebootWarningTimeoutEnabled" -valeur "00000000"
			ecrire_valeurdword_cle_registre -nom_machine "$nom_machine" -ruche "HKLM" -chemin "software\Policies\Microsoft\Windows\WindowsUpdate\AU" -cle "RebootRelaunchTimeoutEnabled" -valeur "00000000"
			}
		}
	}
	
	
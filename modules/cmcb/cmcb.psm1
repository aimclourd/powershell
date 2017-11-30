<#
    .SYNOPSIS
    Module d'intéraction avec CMCB
    
    .DESCRIPTION
    Ce module regroupe toutes les fonctions supplémentaires d'intéraction avec les informations CMCB d'une machine.
	Nécessite le chargement du module registre   
    .LINK
     
    .NOTE
    Auteur: Grégory DAVID (gregory.david@sncf.fr)       
#>

function connexion_cmcb
	{
	# Requires -Version 3.0            
	try
		{
		$ConfigMgrPath = Split-Path -Path "${Env:SMS_ADMIN_UI_PATH}" -ErrorAction Stop
		} 
	catch 
		{
		Write-Warning -Message "Failed to find ConfigMgr environment variable because $($_.Exception.Message)"
		}
	if ($ConfigMgrPath) 
		{
		$ConfigMgrModuleLoaded = $false
		$ConfigMgrConsoleFile = Join-Path -Path $ConfigMgrPath -ChildPath "ConfigurationManager.psd1"
		if (Test-Path -Path $ConfigMgrConsoleFile) 
			{
			try 
				{
				Write-Verbose -Message "Loading ConfigMgr module from $ConfigMgrConsoleFile" -Verbose
				Import-Module $ConfigMgrConsoleFile -ErrorAction Stop
				$ConfigMgrModuleLoaded = $true
				}
			catch 
				{
				Write-Warning -Message "Failed to load ConfigMgr 2012 SP1 module because $($_.Exception.Message)"
				}
			if ($ConfigMgrModuleLoaded) 
				{
				# Change the title of the console
				$Host.UI.RawUI.WindowTitle = "$($Host.UI.RawUI.WindowTitle) 32bit (running as $($env:USERNAME))"
				try 
					{
					$ConfigMgrPSProvider = Get-PSDrive -PSProvider CMSite -ErrorAction Stop
					}
				catch 
					{
					Write-Warning -Message "Failed to find the PSProvider for ConfigMgr 2012 SP1"    
					}
				if ($ConfigMgrPSProvider) 
					{
					'Your ConfigMgr Site server is: {0}' -f ($ConfigMgrPSProvider).SiteServer
					'Your ConfigMgr Site   code is: {0}' -f ($ConfigMgrPSProvider).SiteCode
					cd "$($ConfigMgrPSProvider.SiteCode):\"
					try 
						{
						Update-Help -Module ConfigurationManager -Force -ErrorAction Stop
						} 
					catch 
						{
						Write-Warning -Message "Failed to update the help of the ConfigurationManager module because $($_.Exception.Message)"
						}
					}
				}
			} 
		else 
			{
			Write-Warning -Message "ConfigMgr 2012 SP1 module not found"
			}
		}	          
	if ($pshome -eq "$($env:windir)\SysWOW64\WindowsPowerShell\v1.0") 
		{            
		Write-Verbose -Message "Trying to load ConfigMgr 2012 SP1 module if appropriate" -Verbose            
		Invoke-Expression -Command $ConfigMgrConsoleCode            
		} 
	else 
		{            
		#Write-Verbose -Message "Launching a 32bit powershell console to load ConfigMgr 2012 SP1 module" -Verbose            
		#Start-Process -FilePath "$($env:windir)\SysWOW64\WindowsPowerShell\v1.0\PowerShell.exe" -Verb Runas             
		}
	}
	
function recuperer_membres_collection_cmcb
	{
	param($nom_collection)
	connexion_cmcb
	$membres_collection = Get-CMCollectionMember -CollectionName $nom_collection
	foreach ($membre in $membres_collection)
		{
		$nom_serveur = $membre.name
		$domaine_serveur = $membre.Domain
		$site_ad_serveur = $membre.ADSiteName		
		$mp_serveur = $membre.LastMPServerName		
		$os_serveur = $membre.DeviceOS
		write-output "$nom_serveur|$domaine_serveur|$site_ad_serveur|$os_serveur|$mp_serveur"
		}
	}	
	$serveurs_sous_cmcb = recuperer_membres_collection_cmcb -nom_collection "mycollection"
	Import-Module sqlserver -Force	
	if (test-path "C:\mypath\requetes_export_cmcb.txt")
		{
		remove-item "C:\mypath\requetes_export_cmcb.txt" -force
		}
	$connexion_sqlserver = ouvrir_connexion_sqlserver -serveur_sqlserver "myserver" -user_sqlserver "myuser" -password_user_sqlserver "pwd_myuser" -database_sqlserver "mydatabase" -verbose $true
	foreach ($ligne in $serveurs_sous_cmcb)
		{
		$infos_ligne = $ligne.split("|")
		$nom_complet = $infos_ligne[0]
		$domaine = $infos_ligne[1]
		$site_ad = $infos_ligne[2]
		$os = $infos_ligne[3]		
		$mp = $infos_ligne[4]		
		$requete_insert = "USE [mydatabase] 
			DELETE FROM [dbo].[mytable] WHERE Nom_Complet = '$Nom_complet'			
			INSERT INTO [dbo].[mytable]
		           ([Nom_Complet]
		           ,[Nom]
		           ,[Domaine]
		           ,[Domaine_Complet]
				   ,[Site_AD]
		           ,[OS]
		           ,[MP]
				   ,[Date_Export])
		     VALUES
		           ('$Nom_complet',
		           '$Nom_complet',
				   '$domaine',
				   '$domaine',
				   '$site_ad',
				   '$os',
				   '$mp',
				   GetDate())"
		$requete_insert | out-file C:\mypath\requetes_export_cmcb.txt -append
		executer_requete_sqlserver -requete_sqlserver $requete_insert -connexion_sqlserver $connexion_sqlserver	
		}
	fermer_connexion_sqlserver -connexion_sqlserver $connexion_sqlserver
	}
	
function recuperer_membres_collection_cmcb_wmi
	{
	param ($nom_serveur,
	$code_site,
	$nom_collection)
 
	$Collection = get-wmiobject -ComputerName $nom_serveur -NameSpace "ROOT\SMS\site_$code_site" -Class SMS_Collection   | where {$_.Name -eq "$nom_collection"}
  	$SMSClients = Get-WmiObject -ComputerName $nom_serveur -Namespace  "ROOT\SMS\site_$code_site" -Query "SELECT * FROM SMS_FullCollectionMembership WHERE CollectionID='$($Collection.CollectionID)' order by name" 
 	foreach ($client in $SMSClients)
		{
		$client | fl *
		$domaine_client = $client.domain 
		$nom_client = $client.Name
		if ($domaine_client -eq "mydomain")
			{
			$nom_complet_client = "$nom_client.mydomain"
			}
		Write-Output $nom_complet_client
		}
	} 
<#
    .SYNOPSIS
    Module d'intéraction avec SCCM
    
    .DESCRIPTION
    Ce module regroupe toutes les fonctions supplémentaires d'intéraction avec les informations SCCM d'une machine.
	Nécessite le chargement du module registre   
    .LINK
     
    .NOTE
    Auteur: Grégory DAVID (gregory.david@sncf.fr)       
#>

function lister_derniers_patch_installes
	{
	param(
		$nom_machine,		
		[parameter(Position=0, Mandatory=$false)]
		[ValidateSet('7J','30J','90J','180J','Tous')]
		[String]$intervalle,
		$login
		)
	cls				
	if ($intervalle -ne "Tous")
		{
		[int]$intervalle = $intervalle.replace("J","")
		}
	else
		{
		[int]$intervalle = $intervalle.replace("Tous","999999")
		}
	$date_intervalle = (Get-Date).adddays(-$intervalle)
	if ($login)
		{		
		$patchs = Get-HotFix -ComputerName $nom_machine -Credential $login 
		}
	else
		{		
		$patchs = Get-HotFix -ComputerName $nom_machine
		}
		foreach ($patch in $patchs)
			{
			$date_install_patch = $patch.installedon
			
			
			if ($date_install_patch)
				{
				$date_install_patch_2 = $date_install_patch -split("/")
				$jour_install_patch = $date_install_patch_2[1]
				$mois_install_patch = $date_install_patch_2[0]
				$annee_install_patch = $date_install_patch_2[2]
				$date_install_patch_fr = Get-Date "$jour_install_patch/$mois_install_patch/$annee_install_patch"				
				}
				
			$id_patch = $patch.HotFixID
			if (($date_install_patch_fr) -and ($date_install_patch_fr -gt $date_intervalle))
				{
				$liste_patchs += "`n"
				$liste_patchs += "$id_patch|$date_install_patch_fr"
				}
			}
		write-output $liste_patchs
	}
	
function recuperer_membres_collection_sccm
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
	
function declencher_scan
	{
	wmic /namespace:\\root\ccm\invagt path inventoryActionStatus where InventoryActionID="{00000000-0000-0000-0000-000000000001}" DELETE /NOINTERACTIVE
	wmic /namespace:\\root\ccm\scheduler path CCM_Scheduler_History where ScheduleID="{00000000-0000-0000-0000-000000000001}" DELETE /NOINTERACTIVE
	WMIC /namespace:\\root\ccm path sms_client CALL TriggerSchedule "{00000000-0000-0000-0000-000000000001}" /NOINTERACTIVE
	
	wmic /namespace:\\root\ccm\invagt path inventoryActionStatus where InventoryActionID="{00000000-0000-0000-0000-000000000002}" DELETE /NOINTERACTIVE
	wmic /namespace:\\root\ccm\scheduler path CCM_Scheduler_History where ScheduleID="{00000000-0000-0000-0000-000000000002}" DELETE /NOINTERACTIVE
	WMIC /namespace:\\root\ccm path sms_client CALL TriggerSchedule "{00000000-0000-0000-0000-000000000002}" /NOINTERACTIVE
	}
						  
<#
    .SYNOPSIS
    Module d'intéraction avec le réseau
    
    .DESCRIPTION
    Ce module regroupe toutes les fonctions supplémentaires d'intéraction avec les paramètres réseau d'une machine.
	        
    .LINK
     
    .NOTE
    Auteur: Grégory DAVID (gregory.david@sncf.fr)       
#>

function verifier_si_ip_fixe
	{
	$cartes_reseau = Get-WMIObject Win32_NetworkAdapterConfiguration | where{$_.IPEnabled -eq “TRUE”}
	Foreach($carte in $cartes_reseau)
		{
		$dhcp_active = $carte.DHCPEnabled
		$ip_carte = $carte.IPAddress
		$nom_carte = $carte.ServiceName
		Write-Output $dhcp_active
		}
	}
function recuperer_adresse_ip
	{
	$adresses = Get-WmiObject -Class Win32_NetworkAdapterconfiguration | where {($_.DNSDomain -eq "mydnsdomain") -or ($_.ipaddress -like "*myip*")}
	$liste_adresses = @()	

	foreach ($adresse in $adresses)
		{
		$obj = New-Object Psobject			
		$adresse_ip = $adresse.ipaddress
		$adresse_ipv4 = $adresse_ip[0]
		$obj | Add-Member -Name "ipv4" -MemberType NoteProperty -Value $adresse_ipv4
		$adresse_ipv6 = $adresse_ip[1]
		$obj | Add-Member -Name "ipv6" -MemberType NoteProperty -Value $adresse_ipv6
		$adresse_mac = $adresse.macaddress
		$obj | Add-Member -Name "mac" -MemberType NoteProperty -Value $adresse_mac
		$dhcp_active = $adresse.DHCPEnabled
		$obj | Add-Member -Name "dhcp_active" -MemberType NoteProperty -Value $dhcp_active
		$liste_adresses += $obj
		}
	Write-Output $liste_adresses
	}
function recuperer_adresse_mac
	{
		param ([string]$nom=$(Throw "Nom de l'ordinateur obligatoire!"))
		Get-WmiObject -Class Win32_networkadapter -ComputerName $nom |
		select-object    @{e={$_.name};n="Nom de la carte réseau"},
				 @{e={$_.adaptertype};n="Type de carte"},
            	  		 @{e={$_.MACAddress};n="Adresse MAC"}
	}
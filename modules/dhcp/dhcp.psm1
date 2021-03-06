#-----------------------------------------------------------------------------------------
#-- fonctions_dhcp.ps1 
#--
#-- Auteur : Grégory DAVID (SNCF - 2IL - Administrateur Système Windows)
#--
#-- Contact : gregory.david@sncf.fr
#--
<#
    .SYNOPSIS
    Module d'intéraction avec un serveur DHCP
    
    .DESCRIPTION
    Ce module regroupe toutes les fonctions supplémentaires d'intéraction avec un serveur DHCP
        
    .LINK
     
    .NOTE
    Auteur: Grégory DAVID (gregory.david@sncf.fr)       
#>

function lister_baux_dhcp
	{
	param(
	$nom_serveur,
	$etendue)
	
	$connexion_mysql = ouvrir_connexion_mysql -serveur_mysql "myserver" -port_mysql "3306" -user_mysql "myuser" -password_user_mysql "pwd_myuser" -database_mysql "mydatabase"
	$infos_reservation_dhcp = lister_reservation_dhcp -nom_serveur $nom_serveur -etendue $etendue
	$infos_dhcp = (netsh dhcp server \\$nom_serveur scope $etendue show clients 1)
	$lignes = @()
	#start by looking for lines where there is both IP and MAC present:
	foreach ($ligne in $infos_dhcp)
	{
	
	    if ($ligne -match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"){
		
	        If ($ligne -match "[0-9a-f]{2}[:-][0-9a-f]{2}[:-][0-9a-f]{2}[:-][0-9a-f]{2}[:-][0-9a-f]{2}[:-][0-9a-f]{2}"){ 
			
	            $lignes += $ligne.Trim()
	        }
	    }
	}
	requete_mysql -serveur_mysql "myserver" -port_mysql "3306" -user_mysql "myuser" -password_user_mysql "pwd_myuser" -database_mysql "mydatabase" -requete_mysql "DELETE FROM mytable"
	$liste_baux = @()
	
	foreach ($ligne in $lignes)
		{
		$obj_bail = New-Object Psobject	
		$ligne_decoupee = $ligne.split("-")			
		$adresse_ip = $ligne_decoupee[0]
		$adresse_ip = $adresse_ip -replace (" ","")
		$masque = $ligne_decoupee[1]			
		$adresse_mac =  $ligne_decoupee[2]+$ligne_decoupee[3]+$ligne_decoupee[4]+$ligne_decoupee[5]+$ligne_decoupee[6]+$ligne_decoupee[7]
		$adresse_mac = $adresse_mac -replace (" ","")
		$date_expiration = $ligne_decoupee[8]
		$date_expiration = $date_expiration.replace("'","''")
		if ($date_expiration -like "[0-9]*")
			{
			$date_expiration = Get-Date $date_expiration -Format "yyyy-MM-dd HH:mm:ss"
			}
		else
			{
			$date_expiration = Get-Date (Get-Date).addyears(2000) -Format "yyyy-MM-dd HH:mm:ss"
			}
		$type = $ligne_decoupee[9]
		$nom_machine = $ligne_decoupee[10]
		$nom_machine = $nom_machine -replace (" ","")	
		$nom_machine_court = $nom_machine.split(".")
		$nom_machine_court = $nom_machine_court[0]
		if ($infos_reservation_dhcp -like "*$adresse_ip*")
			{
			$reservation = $true
			}
		else
			{
			$reservation = $false
			}
		$obj_bail | Add-Member -Name "IP" -MemberType NoteProperty -Value $adresse_ip
		$obj_bail | Add-Member -Name "Nom" -MemberType NoteProperty -Value $nom_machine_court[0]
		$obj_bail | Add-Member -Name "MAC" -MemberType NoteProperty -Value $adresse_mac
		$obj_bail | Add-Member -Name "Description" -MemberType NoteProperty -Value $nom_machine
		$obj_bail | Add-Member -Name "Reservation" -MemberType NoteProperty -Value $reservation	
		
		mysql_insert_into -database_mysql mydatabase -port_mysql 3306 -user_mysql myuser -password_user_mysql pwd_myuser -requete_mysql "USE mydatabase;INSERT INTO mytable (ip,machine,adressemac,description,date_expiration,date_mise_a_jour,reservation) VALUES ('$adresse_ip','$nom_machine_court','$adresse_mac','$nom_machine','$date_expiration',NOW(),'$reservation')"	-verbose $false
		$liste_baux += $obj_bail
		}
		fermer_connexion_mysql -connexion_mysql $connexion_mysql
		Write-output $liste_baux
	}
	
function lister_reservation_dhcp
	{
	param(
	$nom_serveur,
	$etendue)
	
	$connexion_mysql = ouvrir_connexion_mysql -serveur_mysql "myserver" -port_mysql "3306" -user_mysql "myuser" -password_user_mysql "pwd_myuser" -database_mysql "mydatabase"
	mysql_delete_from -database_mysql "mydatabase" -port_mysql 3306 -user_mysql "myuser" -password_user_mysql "pwd_myuser" -requete_mysql "USE mydatabase;DELETE FROM mytable"
	$liste_reservations = @()
	$reservations = (netsh dhcp server \\$nom_serveur scope $etendue show reservedip)
	foreach ($reservation in $reservations)
		{
		$obj_reservation = New-Object Psobject
		$ligne_decoupee = $reservation.Split("-") | %{ $_.Trim() } 
		$adresse_ip = $ligne_decoupee[0]
		$adresse_mac = $ligne_decoupee[1]+$ligne_decoupee[2]+$ligne_decoupee[3]+$ligne_decoupee[4]+$ligne_decoupee[5]+$ligne_decoupee[6]
		$obj_reservation |Add-Member "IP" -MemberType NoteProperty -Value $adresse_ip
		$obj_reservation |Add-Member "MAC" -MemberType NoteProperty -Value $adresse_mac
		if ($ligne_decoupee[0] -like "[0-9]*")
			{
			
			mysql_insert_into -database_mysql "mydatabase" -port_mysql 3306 -user_mysql "myuser" -password_user_mysql "pwd_myuser" -requete_mysql "USE mydatabase;INSERT INTO mytable (ip,adressemac) VALUES ('$adresse_ip','$adresse_mac')"		
			$liste_reservations += $obj_reservation
			}
		}
	fermer_connexion_mysql -connexion_mysql $connexion_mysql
	Write-Output $liste_reservations
	}
	
function blacklister_adressemac_dhcp
	{
	param(
	$nom_serveur,
	$etendue,
	$adresse_mac)
	#Write-Host "Blacklist des adresses mac à problème"
	
	$connexion_mysql = ouvrir_connexion_mysql -serveur_mysql "myserver" -port_mysql "3306" -user_mysql "myuser" -password_user_mysql "pwd_myuser" -database_mysql "mydatabase"
	mysql_delete_from -database_mysql "mydatabase" -port_mysql 3306 -user_mysql "myuser" -password_user_mysql "pwd_myuser" -requete_mysql "USE mydatabase;DELETE FROM mytable"
	$adresses = requete_mysql -database_mysql "mydatabase" -port_mysql 3306 -user_mysql "myuser" -password_user_mysql "pwd_myuser" -type_requete "SELECT" -nom_donnee "ip,adressemac,machine" -requete_mysql "USE mydatabase; select ip,MACHINE,adressemac from infos_dhcp_baux where NOT (MACHINE LIKE '%70LIXKG%' OR MACHINE LIKE '%IVLIXKG%' OR MACHINE LIKE '%SRVBACKUP%' OR MACHINE LIKE '%MININT%' OR MACHINE LIKE '%ILO%' OR ((MACHINE LIKE 'P%' OR MACHINE LIKE 'J%' OR MACHINE LIKE 'S%' OR MACHINE LIKE 'X%') AND LENGTH(MACHINE) = 11) OR MACHINE LIKE '%MASTER%')"
	foreach ($adresse in $adresses)
		{
			$adresse_mac = $adresse.adressemac
			$adresse_ip = $adresse.ip
			$nom_machine = $adresse.machine
			if ($adresse_mac -like "[0-9]*")
				{
				mysql_insert_into -database_mysql "mydatabase" -port_mysql 3306 -user_mysql "myuser" -password_user_mysql "pwd_myuser" -requete_mysql "USE mydatabase;INSERT INTO mytable (ip,machine,adressemac,date_mise_a_jour) VALUES ('$adresse_ip','$nom_machine','$adresse_mac',NOW())"		
				}
			$incident_existant = requete_mysql -database_mysql "mydatabase" -port_mysql 3306 -user_mysql "myuser" -password_user_mysql "pwd_myuser" -type_requete "SELECT" -nom_donnee "ip,adressemac,machine" -requete_mysql "USE mydatabase; select id from mytable where machine = '$nom_machine' and type_incident = 'DHCP'"
			$id_incident_existant = $incident_existant.id
			if ($id_incident_existant)
				{
				
				}
			else
				{
				mysql_insert_into -database_mysql "mydatabase" -port_mysql 3306 -user_mysql "myuser" -password_user_mysql "pwd_myuser" -requete_mysql "USE mydatabase;INSERT INTO mytable (nom_utilisateur,machine,type_incident,description_incident,action,etat,date_mise_a_jour,acquitte) VALUES ('','$nom_machine','DHCP','Ajout de l''adresse mac $adresse_mac à la blacklist du DHCP','Ajout à la blacklist','LOG',NOW(),'False')"
				}			
		}
	$adresses = requete_mysql -database_mysql "mydatabase" -port_mysql 3306 -user_mysql "myuser" -password_user_mysql "pwd_myuser" -type_requete "SELECT" -nom_donnee "ip,adressemac,machine" -requete_mysql "USE mydatabase; select ip,machine,adressemac from mytable"
	$liste_adresse_blacklistees = "MAC_ACTION = {DENY}" + "`r`n"
	foreach ($adresse in $adresses)
		{		
			$adresse_mac = $adresse.adressemac
			$adresse_ip = $adresse.ip
			$nom_machine = $adresse.machine
			if ($adresse_mac -like "[0-9]*")
				{
				$liste_adresse_blacklistees += "`r`n" + $adresse_mac + " #" +$nom_machine
				#Write-Host $liste_adresse_blacklistees
				}
		}
	Write-Output $liste_adresse_blacklistees | Out-File -Force "\\$nom_serveur\c$\dhcp\dhcp_blacklist.txt"
	gerer_service -nom_machine $nom_serveur -nom_service dhcpserver -action restart
	fermer_connexion_mysql -connexion_mysql $connexion_mysql
	}

if ($utilisateur_connecte -like "*SCRIPT*")
	{
	lister_baux_dhcp -etendue myscope -nom_serveur mydhcpserver
	lister_reservation_dhcp -etendue myscope -nom_serveur mydhcpserver
	blacklister_adressemac_dhcp -etendue myscope -nom_serveur mydhcpserver
	}
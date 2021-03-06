<#
    .SYNOPSIS
    Module d'intéraction avec l'OS d'une machine
    
    .DESCRIPTION
    Ce module regroupe toutes les fonctions supplémentaires d'intéraction avec l'OS d'une machine.
	Certains scripts nécessite la connexion à une base de données mysql
	
    .LINK
     
    .NOTE
    Auteur: Grégory DAVID (gregory.david@sncf.fr)       
#>
	
function gerer_service
	{
	param(
	$nom_machine,
	$nom_service,
	[parameter(Mandatory=$true)]
	[ValidateSet("Stop","Start","Restart")]
	$action)
	if ($action -eq "Stop")
		{
		get-service -ComputerName $nom_machine -Name $nom_service | Stop-Service -Verbose
		}
	if ($action -eq "Start")
		{
		get-service -ComputerName $nom_machine -Name $nom_service | Start-Service  -Verbose
		}
	if ($action -eq "Restart")
		{
		get-service -ComputerName $nom_machine -Name $nom_service | Stop-Service -Verbose
		get-service -ComputerName $nom_machine -Name $nom_service | Start-Service -Verbose
		}
	}

function verifier_compte_local
	{
	param(
	$nom_machine,
	$nom_utilisateur)
	$compte =[ADSI]"$nom_machine"
	}
	
function lister_compte_locaux
	{
	param(
	$nom_machine)
	$liste_comptes_locaux = @()
	$comptes = @()
	$compte_locaux = Get-WmiObject -Class Win32_UserAccount -Namespace "root\cimv2" -Filter "LocalAccount='$True'" -ComputerName $nom_machine -ErrorAction Stop 
	
	foreach ($compte in $compte_locaux)
		{
		$nom_compte = $compte.name
		$obj = new-object psobject -Property @{
		 nom = $nom_compte
		 }
		$comptes +=$obj
		}
	$liste_comptes_locaux += $comptes
	write-output $liste_comptes_locaux.nom
	}

function lister_membres_groupe_local
	{
	param(
	$nom_machine,
	$nom_groupe,
	$cred)
	
	$liste_membres = @()
	$membres = @()
	if ($cred)
		{
		$nom_court_domaine = (($cred.Username).split("\"))[0]
		$nom_court_domaine = $nom_court_domaine.toupper()
		$nom_machine_court = ($nom_machine.split("."))[0]		
		$nom_machine_court = $nom_machine_court.toupper()		
		#$groupes = Get-WmiObject -Class win32_group -filter "Domain = '$nom_machine'" -ComputerName $nom_machine_court		
		
		$Query = "SELECT * FROM Win32_GroupUser WHERE GroupComponent = `"Win32_Group.Domain='$nom_court_domaine',Name='$nom_groupe'`"" 
		$Query
		$membres = Get-WmiObject -query $Query -Credential $cred -ComputerName $nom_machine  
		$membres
		$membres = Get-WmiObject -query $Query -Credential $cred -ComputerName $nom_machine 
		foreach ($membre in $membres.partcomponent)
			{
			$nom_membre = $membre.name		
			$nom_membre
			if ($partcomponent_membre -contains "$nom_machine_court")
				{
#				
				}
			}
		
		}	
	else
		{
		$group =[ADSI]"WinNT://$nom_machine/$nom_groupe" 		
		$membres= @($group.psbase.Invoke("Members")) | foreach{([ADSI]$_).InvokeGet("Name")}	 
		$liste_membres += $membres
		}
	write-output $liste_membres 
	}
	
function creer_compte_local
	{
	param(
	$nom_machine,
	$nom_utilisateur,
	$password) 

	$objOu = [ADSI]"WinNT://$nom_machine"
	$objUser = $objOU.Create("User",$nom_utilisateur)
	$objUser.setpassword($password)
	$objUser.SetInfo()
	$objUser.description = "$nom_utilisateur"
	$objUser.SetInfo()
	}
	
function ajouter_compte_local_dans_groupe_local
	{
	param(
	$nom_machine,
	$nom_utilisateur,
	$nom_groupe)

	$groupe = [ADSI]"WinNT://$($nom_machine)/$($nom_groupe)"
	$groupe.add($nom_utilisateur.ADsPath)		
	$groupe.SetInfo()
	}

function supprimer_compte_local_dans_groupe_local
	{
	param(
	$nom_machine,
	$nom_utilisateur,
	$nom_groupe)
	$groupe = [ADSI]"WinNT://$($nom_machine)/$($nom_groupe)"	
	$groupe.psbase.Invoke("Remove",([ADSI]"WinNT://$($nom_machine)/$nom_utilisateur").path)			
	$groupe.SetInfo()
	}
	
function ajouter_compte_ad_dans_groupe_local
	{
	param(
	$nom_machine,
	$cp_utilisateur,
	$nom_groupe,
	$withreplace,
	$log_bdd)
	
	$env_user = get_env_user
	$cp_utilisateur_connecte = $env_user[1]
	$nom_utilisateur_connecte = $env_user[2]
	
	if ($withreplace)
		{
		$liste_membres = lister_membres_groupe_local -nom_machine $nom_machine -nom_groupe $nom_groupe
		foreach ($membre in $liste_membres)
			{
			Write-Host "Suppression du compte $membre"
			supprimer_compte_ad_dans_groupe_local -nom_machine $nom_machine -cp_utilisateur $membre -nom_groupe $nom_groupe			
			if ($log_bdd)
				{
				Import-Module mysql
				$connexion_mysql = ouvrir_connexion_mysql -serveur_mysql "myserver" -port_mysql "3306" -user_mysql "myuser" -password_user_mysql "pwd_myuser" -database_mysql "mydatabase"
				requete_mysql -serveur_mysql "myserver" -port_mysql "3306" -user_mysql "myuser" -password_user_mysql "pwd_myuser" -database_mysql "mydatabase" -requete_mysql "INSERT INTO mytable (id,description,type_action,date_action,nom_auteur_action,cp_auteur_action) VALUES ('$cp_utilisateur','Suppression de l''utilisateur du groupe $nom_groupe sur le poste $nom_machine','Suppression d''un groupe', NOW(), '$nom_utilisateur_connecte', '$cp_utilisateur_connecte')"				
				fermer_connexion_mysql $connexion_mysql
				Remove-Module mysql
				}
			}
		}
	$groupe = [ADSI]"WinNT://$($nom_machine)/$($nom_groupe)"
	$groupe.psbase.Invoke("Add",([ADSI]"WinNT://COMMUN/$cp_utilisateur").path)			
	$groupe.SetInfo()
	if ($log_bdd)
		{
		Import-Module mysql
		$connexion_mysql = ouvrir_connexion_mysql -serveur_mysql "myserver" -port_mysql "3306" -user_mysql "myuser" -password_user_mysql "pwd_myuser" -database_mysql "mydatabase"
		requete_mysql -serveur_mysql "myserver" -port_mysql "3306" -user_mysql "myuser" -password_user_mysql "pwd_myuser" -database_mysql "mydatabase" -requete_mysql "INSERT INTO mytable (id,description,type_action,date_action,nom_auteur_action,cp_auteur_action) VALUES ('$cp_utilisateur','Ajout de l''utilisateur dans le groupe $nom_groupe sur le poste $nom_machine','Ajout à un groupe', NOW(), '$nom_utilisateur_connecte', '$cp_utilisateur_connecte')"
		fermer_connexion_mysql $connexion_mysql
		Remove-Module mysql
		}
	}

function supprimer_compte_ad_dans_groupe_local
	{
	param(
	$nom_machine,
	$cp_utilisateur,
	$nom_groupe,
	$log_bdd)

	$env_user = get_env_user
	$cp_utilisateur_connecte = $env_user[1]
	$nom_utilisateur_connecte = $env_user[2]
	$groupe = [ADSI]"WinNT://$($nom_machine)/$($nom_groupe)"
	$groupe.psbase.Invoke("Remove",([ADSI]"WinNT://mydomain/$cp_utilisateur").path)			
	$groupe.SetInfo()
	if ($log_bdd)
		{
		Import-Module mysql
		$connexion_mysql = ouvrir_connexion_mysql -serveur_mysql "myserver" -port_mysql "3306" -user_mysql "myuser" -password_user_mysql "pwd_myuser" -database_mysql "mydatabase"
		requete_mysql -serveur_mysql "myserver" -port_mysql "3306" -user_mysql "myuser" -password_user_mysql "pwd_myuser" -database_mysql "mydatabase" -requete_mysql "INSERT INTO mytable (id,description,type_action,date_action,nom_auteur_action,cp_auteur_action) VALUES ('$cp_utilisateur','Suppression de l''utilisateur du groupe $nom_groupe sur le poste $nom_machine','Suppression d''un groupe', NOW(), '$nom_utilisateur_connecte', '$cp_utilisateur_connecte')"	
		fermer_connexion_mysql $connexion_mysql
		Remove-Module mysql
		}
	}
	
function verifier_droits_admin_compte_local
	{
	param(
	$nom_machine,
	$nom_utilisateur,
	$pwd_utilisateur,
	$log_bdd)
	$group =[ADSI]"WinNT://$nom_machine/Administrateurs" 
	$members = @($group.psbase.Invoke("Members")) 
	$admins = $members | foreach {$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)}
	Add-Type -assemblyname system.DirectoryServices.accountmanagement 
	$DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Machine)
	$verification = $DS.ValidateCredentials("$nom_utilisateur", "$pwd_utilisateur") 
	Write-Output $verification
	}

function calculer_difference_entre_date
	{
	param(
	[parameter(Mandatory=$true)]
	[ValidateSet("Minutes","Seconds","Hours","Days")]
	$unite,
	$date_1,
	$date_2)

	$date_1=(GET-DATE $date_1)
	$date_2=(GET-DATE $date_2)

	$duree = NEW-TIMESPAN –Start $date_1 –End $date_2	
	Write-Output $duree.$unite
	}
	
function afficher_popup
	{
	param([string]$nom_poste,
	[string]$message,
	[string]$expediteur)

	if (!($expediteur))
		{
		$expediteur = [Environment]::UserName
		}
		$infos_ad_expediteur = get-qaduser $expediteur -SearchRoot "myou" 
		$nom_expediteur = $infos_ad_expediteur.name
	if (!($nom_poste))
		{
		$nom_poste = read-host "Veuillez entrer le nom du poste"
		}
	if (!($message))
		{
		$message = read-host "Veuillez entrer le message"
		$message = "Message de $nom_expediteur : " + $message
		}
	else
		{
		$message = "Message de $nom_expediteur : " + $message
		}
	#$session = New-PSSession -ComputerName $nom_poste
	#invoke-Command -session $session -Script {param($message) msg.exe * "$message"} -ArgumentList $message
	invoke-Command -computername $nom_poste -ScriptBlock {param($message) msg.exe * "$message"} -ArgumentList $message
	}
	
function supprimer_dernier_caractere
	{
	param(
	$variable)
	$variable_modifiee = $variable -replace ".$"
	Write-Output $variable_modifiee
	}

function supprimer_caractere
	{
	param(
	$variable,
	$caractere)
	$regex = [regex]$caractere
	$variable_modifiee = $regex.Replace([string]::Join("`n",$variable), '')
 	Write-Output $variable_modifiee	
	}
	
function supprimer_caractere_selon_position
	{
	param(
	$variable,
	$position)
 	$variable_modifiee=$variable -replace('^(.{$position}).', '$1+')
	Write-Output $variable_modifiee
	}
	
function envoyer_mail_auto
	{	
	param(
	$expediteur,
	$destinataire,
	$object,
	$corps_mail,
	$piece_jointe,
	$html,
	$dryrun)
	
	if ($corps_mail -like "*.txt")
	{
	$corps_mail = Get-Content $corps_mail
	}
	# On prépare le mail
	$serveur = "myserver"
	Write-Host $serveur
	#$corps_mail = $corps_mail | ConvertTo-Html
	#On ajout les destinataires en copie
	if ($destinataire)
		{
		$mails = $destinataire.split(";")
		$nombre_adresses = $mails.count	
		#Write-Host "Nombre d'adresses : $nombre_adresses"
		$i=0
		while ($i -lt $nombre_adresses)
			{
			#Write-host "Destinataire No $i $mails[$i]"
			#Write-Host $mails[$i]
			if ($i -eq 0)
				{
				$message = new-object System.Net.Mail.MailMessage $expediteur, $mails[$i], $object, $corps_mail
				}
			if ($i -gt 0)			
				{				
				$message.cc.add($mails[$i])
				}
			$i++
			}
		}
	
	#On attache une pièce jointe
	if (($piece_jointe) -and ($piece_jointe -notlike "pas_de_pj"))
		{		
		#Write-Host "Ajout d'une PJ"
		$attachment = new-object System.Net.Mail.Attachment $piece_jointe
		$message.Attachments.Add($attachment)
		}
	if ($html -eq $true)	
		{$message.IsBodyHTML = $true}
		else
		{$message.IsBodyHTML = $false}
	$SMTPclient = new-object System.Net.Mail.SmtpClient $serveur
	$SMTPclient.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
	$SMTPclient | fl *
	if ($dryrun -eq "Oui")
		{
		Write-Host "Pas d'envoi de mail"
		}
	else
		{
		# On envoie le mail
		$SMTPclient.Send($message)
		}
	}

function recuperer_sid_carte_reseau
	{
	param($carte_reseau)
	
	$liste_sids = gci "HKLM:\SYSTEM\CurrentControlSet\Control\Network\{4D36E972-E325-11CE-BFC1-08002BE10318}"
	foreach ($sid in $liste_sids)
		{
		#$sid | fl *
		$nom_sid = $sid.pspath
		$nom_sid = $nom_sid.replace("Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\","HKLM:\")
		$nom_sid =$nom_sid+"\Connection\"
		$proprietes_sid = Get-ItemProperty $nom_sid -ErrorAction:SilentlyContinue
		$nom_carte_reseau = $proprietes_sid.name
		#write-host "$nom_carte_reseau $carte_reseau"
		if (($carte_reseau) -and ($nom_carte_reseau -eq $carte_reseau))
			{
			Write-Host "$nom_carte_reseau $nom_sid"
			}
		}
	}
	
function recuperer_fichier_le_plus_recent
	{
	param($repertoire_fichier,
			$extension_fichier,
			$nom_fichier)
	if (($extension_fichier) -and (!($nom_fichier)))
		{
		#Write-Host "cas 1"
		$extension_fichier= "*." + $extension_fichier
		$fichier = gci -path $repertoire_fichier -filter $extension_fichier -ErrorAction:SilentlyContinue | sort LastWriteTime | select -last 1
		$fichier.name
		}
	if (($extension_fichier) -and ($nom_fichier))
		{
		#Write-Host "cas 2"
		$extension_fichier= "*." + $extension_fichier
		$fichier = gci -path $repertoire_fichier -filter $extension_fichier -ErrorAction:SilentlyContinue | where {$_.name -like "*$nom_fichier*"} | sort LastWriteTime | select -last 1
		$fichier.name
		}
	if ((!($extension_fichier)) -and ($nom_fichier))
		{
		#Write-Host "cas 3"
		$extension_fichier= "*." + $extension_fichier
		$fichier = gci -path $repertoire_fichier -ErrorAction:SilentlyContinue | where {$_.name -like "*$nom_fichier*"} | sort LastWriteTime | select -last 1
		$fichier.name
		}
	if ((!($extension_fichier)) -and (!($nom_fichier)))
		{
		#Write-Host "cas 4"
		$extension_fichier= "*." + $extension_fichier
		$fichier = gci -path $repertoire_fichier -ErrorAction:SilentlyContinue  | sort LastWriteTime | select -last 1
		$fichier.name
		}
	}

function get_uptime
	{
	param ($nom_machine)
	$lastboottime = (Get-WmiObject -Class Win32_OperatingSystem -computername $nom_machine).LastBootUpTime

	$sysuptime = (Get-Date) – [System.Management.ManagementDateTimeconverter]::ToDateTime($lastboottime) 
	$nb_jours = $sysuptime.days
	$nb_heures = $sysuptime.hours
	$nb_minutes = $sysuptime.minutes
	$nb_secondes = $sysuptime.seconds

	Write-Host "$nom_machine has been up for: " $sysuptime.days "days" $sysuptime.hours "hours" $sysuptime.minutes "minutes" $sysuptime.seconds "seconds"

	$date = (Get-Date).adddays(-$nb_jours)
	$date = (Get-Date $date).addhours(-$nb_heures)
	$date = (Get-Date $date).addminutes(-$nb_minutes)
	$date = (Get-Date $date).addseconds(-$nb_secondes)
	}
	
function afficher_boite_dialogue_validation
	{
	[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

	$caption = "Warning!"
	$message = "Voulez vous continuer?"
	$yesNoButtons = 4

	if ([System.Windows.Forms.MessageBox]::Show($message, $caption, $yesNoButtons) -eq "NO") 
		{
		"Vous avez répondu Non"
		$global:reponse = $false
		}
	else 
		{
		"Vous avez répondu Oui"
		$global:reponse = $true
		}
	}

function saisir_validation
	{
	param($message)
	$oui = New-Object System.Management.Automation.Host.ChoiceDescription "&Oui",""
	$non = New-Object System.Management.Automation.Host.ChoiceDescription "&Non",""
	$choices = [System.Management.Automation.Host.ChoiceDescription[]]($oui,$non)
	$caption = ""
	if (!($message))	
		{
		$message = "Voulez vous continuer?"
		}
	$result = $Host.UI.PromptForChoice($caption,$message,$choices,0)
	if($result -eq 0) 
		{
		Write-output "Y"		
		}
	if($result -eq 1) 
		{
		Write-output "N"		
		}
	}
	
function arreter_process
	{
	param($nom_machine,
		$nom_process)
	(Get-WmiObject Win32_Process -ComputerName $nom_machine | ?{ $_.ProcessName -match "$nom_process" }).Terminate()
	}
	
function lire_ligne_fichier
	{
	param($nom_fichier,
	$numero_ligne)
	if ($numero_ligne -gt 1)
		{
		$contenu_ligne = (get-content $nom_fichier -totalcount $numero_ligne)[-1]		
		}
	if ($numero_ligne -eq 1)
		{
		$contenu_ligne = get-content $nom_fichier -totalcount $numero_ligne
		}
	if ($numero_ligne -eq 0)
		{
		$contenu_ligne = (get-content $nom_fichier -totalcount (get-content $nom_fichier).count)[-1]	
		}
	Write-Output $contenu_ligne
	}
		
function stress_cpu
	{
	$result = 1
	foreach ($number in 1..2147483647) {$result = $result * $number}
	}
	
function determiner_os_avec_ping
	{
	param($nom_machine,
	$export_nom_machine)
	$TimeToLive = Test-Connection $nom_machine -Count 1 | select -exp ResponseTimeToLive
	if ($TimeToLive)
	{
		if ($export_nom_machine)
			{
				Switch($TimeToLive)
				{
					{$_ -le 64} {"$nom_machine|Linux"; break}
					{$_ -le 128} {"$nom_machine|Windows"; break}
					{$_ -le 255} {"$nom_machine|UNIX"; break}
				}
			}
		else
			{
				Switch($TimeToLive)
				{
					{$_ -le 64} {"Linux"; break}
					{$_ -le 128} {"Windows"; break}
					{$_ -le 255} {"UNIX"; break}
				}
			}
	}
	else
	{
	write-output "$nom_machine|pingko"
	}
	}
	
function recuperer_date_dernier_reboot
	{	
	param($nom_machine,$identifiants)
	if ($identifiants)
		{
		$info_dernier_reboot = Get-WmiObject win32_operatingsystem -Credential $identifiants -ComputerName $nom_machine | select csname, @{LABEL=’LastBootUpTime’;EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}
		}
	else
		{
		$info_dernier_reboot = Get-WmiObject win32_operatingsystem -ComputerName $nom_machine | select csname, @{LABEL=’LastBootUpTime’;EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}
		}
	$date_dernier_reboot = $info_dernier_reboot.lastbootuptime
	Write-Output $date_dernier_reboot
	}
	
function recuperer_sysinternal_tools
	{
	$DestinationFolder = "C:\sysint"
 	Write-Host "Connecting"
	New-PSDrive -Name SysInt -PSProvider FileSystem -Root "https://live.sysinternals.com/"
	$Files = Get-ChildItem -Path SysInt:\ -Recurse
	 
	Write-Host "Copying"
	$Copied = 0
	foreach($File in $Files){
	    Write-Progress -Activity "Update SysInt" -Status $File.Name -PercentComplete ($Copied / $Files.Count * 100)
	    Copy-Item -Path $File.FullName -Destination $DestinationFolder -Force
	    $Copied++
	}
	Write-Progress -Activity "Update SysInt" -Completed
	 
	Write-Host "Tidying up"
	Remove-PSDrive -Name SysInt -PSProvider FileSystem
	}
	
function recuperer_dernieres_connexions
	{
	param($nom_machine)
	$infos_os = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $nom_machine
	$version_os = $infos_os.Version
	if ($version_os -like "6.*")
		{
		$liste_connexions = Get-ChildItem "\\$nom_machine\c$\users" | Sort-Object lastwritetime -Descending
		}
	
	if ($version_os -like "5.*")
		{
		$liste_connexions = Get-ChildItem "\\$nom_machine\c$\Documents and settings"
		}
	if ($version_os -like "5.*")
		{
		$liste_connexions = Get-ChildItem "\\$nom_machine\c$\WINNT\Profiles"
		}
	foreach ($connexion in $liste_connexions)
		{
		$nom_utilisateur = $connexion.name
		$date_derniere_connexion = $connexion.lastwritetime
		$date_derniere_connexion = Get-Date $date_derniere_connexion -Format "dd/MM/yyyy HH:mm:ss"
		Write-Host "$nom_utilisateur $date_derniere_connexion"
		}
	}
	
function monter_lecteur
	{
	param($repertoire_distant,
	$nom_lecteur)
	cls

	$global:cred = Get-Credential

	Write-host "Création du lecteur $nom_lecteur pointant sur $repertoire_distant"
	
	$Drive = "\\myserver\c$"

	New-PSDrive -Name $nom_lecteur -PSProvider FileSystem -Credential $global:cred -Root $repertoire_distant 
	}

function demonter_lecteur
	{
	param($nom_lecteur)
	Remove-PSDrive -Name $nom_lecteur
	}

function ping_rapide
	{
	param($nom_machine)
	[int]$delay = 100
	$ping = new-object System.Net.NetworkInformation.Ping
	$test_ping =""
	$status_test_ping = ""
	$test_ping = $ping.send($nom_machine,$delay)
	$status_test_ping = $test_ping.status
	Write-output "$nom_machine : $status_test_ping" 
	}

function recuperer_infos_os
	{
	param($nom_machine,
	$export_nom_machine,
	$set_credential)
	$toutes_infos_os = @()
	
	$infos_os = (Get-WmiObject -Class win32_operatingsystem -ComputerName $nom_machine -ErrorAction:SilentlyContinue)
	if (($error[0] -like "*denied*") -or ($error[0] -like "*refus*"))
		{
		$global:acces_refuse = $true
		}
	else
		{		
		$global:acces_refuse = $false
		$objinfos = New-Object Psobject			
		$os_caption = $infos_os.caption
		$os_install_date = $infos_os.installdate
		$os_install_date_2 = $os_install_date.substring(6,2)+"/"+$os_install_date.substring(4,2)+"/"+$os_install_date.substring(0,4)+" "+$os_install_date.substring(8,2)+":"+$os_install_date.substring(10,2)
		$os_lastboot = $infos_os.lastbootuptime
		$os_lastboot_2 = $os_lastboot.substring(6,2)+"/"+$os_lastboot.substring(4,2)+"/"+$os_lastboot.substring(0,4)+" "+$os_lastboot.substring(8,2)+":"+$os_lastboot.substring(10,2)
		$os_architecture = $infos_os.osarchitecture
		if (($os_architecture -notlike "*64*") -and ($os_caption -like "*64*"))
			{
			$os_architecture = "64 bits"
			}
		if (!($os_architecture))
			{
			$os_architecture = "32 bits"
			}
		$os_language = $infos_os.oslanguage
		$os_systemdrive = $infos_os.systemdrive
		$os_windowsdirectory = $infos_os.windowsdirectory
		$os_systemdirectory = $infos_os.systemdirectory
		$os_csname = $infos_os.csname
		$os_version = $infos_os.version
		


		$objinfos | Add-Member -Name "Caption" -MemberType NoteProperty -Value $os_caption 
		$objinfos | Add-Member -Name "Install_Date" -MemberType NoteProperty -Value $os_install_date_2 
		$objinfos | Add-Member -Name "Last_Boot_Date" -MemberType NoteProperty -Value $os_lastboot_2 
		$objinfos | Add-Member -Name "Architecture" -MemberType NoteProperty -Value $os_architecture 
		$objinfos | Add-Member -Name "Language" -MemberType NoteProperty -Value $os_language 
		$objinfos | Add-Member -Name "System_Drive" -MemberType NoteProperty -Value $os_systemdrive 
		$objinfos | Add-Member -Name "Windows_Directory" -MemberType NoteProperty -Value $os_windowsdirectory 
		$objinfos | Add-Member -Name "System_Directory" -MemberType NoteProperty -Value $os_systemdirectory 
		$objinfos | Add-Member -Name "Csname" -MemberType NoteProperty -Value $os_csname 
		$objinfos | Add-Member -Name "Version" -MemberType NoteProperty -Value $os_version 
		$objinfos | Add-Member -Name "nom_machine" -MemberType NoteProperty -Value $nom_machine 
		
		$toutes_infos_os += $objinfos
		}
	write-output $toutes_infos_os
	}
	
function lister_partition
	{
	param($nom_machine)
	$infos_disques = Get-WmiObject -class win32_logicaldisk -ComputerName $nom_machine | where {$_.drivetype -eq 3} 
	$lecteurs = ""
	foreach ($info in $infos_disques)
		{
		$nom_lecteur = $info.deviceID
		$lecteurs += "$nom_lecteur;"
		write-output "$nom_machine|$nom_lecteur" 
		}
	}
	
function tester_suffixe_dns
	{
	param($nom_machine,
	$suffixe_dns)
	if ($suffixe_dns)
		{
		$nom_machine_avec_dns = $nom_machine+"."+$suffixe_dns
		$test_ping = Test-Connection -ComputerName $nom_machine_avec_dns -Quiet
		$test_ping
		$suffixes_ok = $suffixe_dns
		}
	Write-Output $suffixes_ok
	}
	
function recuperer_version_agent_wua
	{
	param($nom_machine)
	if ($nom_machine)
		{
		$infos_os_machine = recuperer_infos_os -nom_machine $nom_machine
		$repertoire_windows = $infos_os_machine.Windows_Directory
		$repertoire_windows = $repertoire_windows.replace(":","$")
		$infos_version_wua = (Get-ItemProperty -Path "\\$nom_machine\$repertoire_windows\System32\wuaueng.dll").VersionInfo
		}
	else
		{
		$infos_version_wua = (Get-ItemProperty -Path "$($env:windir)\System32\wuaueng.dll").VersionInfo
		}
	$version_wua = $infos_version_wua.ProductVersion
	Write-Output $version_wua
	}
	
function lister_variables_definies
	{
	$variables = get-variable | Where -Property PSProvider -like "Microsoft.PowerShell.Core\Variable"
	foreach ($variable in $variables)
		{
		$nom_variable = $variable.name
		$valeur_variable = $variable.value
		$visibilite_variable = $variable.visibility
		Write-Output "$nom_variable|$valeur_variable|$visibilite_variable"
		}
	}
	
function arreter_service_wmi
	{
	param($nom_machine,
	$nom_service)
	$service = Get-WmiObject -class win32_service -ComputerName $nom_machine -filter "name='$nom_service'"
	$arret = $service.stopservice()	
	$resultat_arret = $arret.returnvalue
	if ($resultat_arret -eq 0)
		{
		Write-output "Arrêt du service $nom_service sur la machine $nom_machine réussi"
		}
	else
		{
		Write-output "Arrêt du service $nom_service sur la machine $nom_machine en erreur"
		}
	}

function demarrer_service_wmi
	{
	param($nom_machine,
	$nom_service)
	$service = Get-WmiObject -class win32_service -ComputerName $nom_machine -filter "name='$nom_service'"
	$demarrage = $service.startservice()
	$resultat_demarrage = $demarrage.returnvalue
	if ($resultat_demarrage -eq 0)
		{
		Write-output "Démarrage du service $nom_service sur la machine $nom_machine réussi"
		}
	else
		{
		Write-output "Démarrage du service $nom_service sur la machine $nom_machine en erreur"
		}
	}
	
function changer_mode_demarrage_service_wmi
	{
	param($nom_machine,
	$nom_service,
	[parameter(Mandatory=$true)]
	[ValidateSet("Automatic","Manual","Disabled","Boot","System")]
	$mode_demarrage)
	$service = Get-WmiObject -class win32_service -ComputerName $nom_machine -filter "name='$nom_service'"
	$modification = $service.changestartmode("manual") 
	$resultat_modification = $modification.returnvalue
	if ($resultat_demarrage -eq 0)
		{
		Write-output "Le mode de démarrage du service $nom_service sur la machine $nom_machine est maintenant : $mode_demarrage"
		}
	else
		{
		Write-output "Modification du mode de démarrage du service $nom_service sur la machine $nom_machine en erreur"
		}
	}
	
function lancer_executable_distant
	{
	param($nom_machine,
	$executable,
	$parametres)	
	$commandline = "$executable $parametres"
	$sb = [ScriptBlock]::Create($commandline)	
	Invoke-Command -computername $nom_machine -ScriptBlock $sb -AsJob
	}
	
function lancer_executable_distant_wmi
	{
	param($nom_machine,
	$executable,
	$parametres)	
	$commandline = "$executable $parametres"
	Write-Output $commandline
	Invoke-WMIMethod -Class Win32_Process -Name Create -ArgumentList "$commandline" -ComputerName $nom_machine 
	}
	
function lancer_nmcap
	{
	param($nom_machine,
	$executable,
	$parametres)
	$date = Get-Date -Format HH-mm-ss	
	$commandline = "nmcap.exe /network * /capture /file C:\temp\log_$date.cap /stopwhen /timeafter 120"
	write-output $commandline
	$sb = [ScriptBlock]::Create($commandline)	
	$sb | fl *
	Invoke-Command -computername $nom_machine -ScriptBlock $sb -AsJob
	}
	
function lancer_mmc_dns
	{
	param($nom_domaine)
	$ip_dc = recuperer_ip_dc -nom_domaine $nom_domaine
	$login_domaine = recuperer_infos_connexion_domaine -nom_domaine $nom_domaine		
	$commande = "runas /netonly /user:$login_domaine "+'"'+"mmc dnsmgmt.msc"+'"'
	$commande
	cmd /c $commande
	}
	
function lancer_mmc_dsa
	{
	param($nom_domaine)
	$ip_dc = recuperer_ip_dc -nom_domaine $nom_domaine
	$login_domaine = recuperer_infos_connexion_domaine -nom_domaine $nom_domaine		
	$commande = "runas /netonly /user:$login_domaine "+'"'+"mmc dsa.msc /server=$ip_dc"+'"'
	$commande
	cmd /c $commande
	}
	
function changer_profil_carte_reseau
	{
	param($nom_carte_reseau,
	$profile)
	$Profile_carte = Get-NetConnectionProfile -InterfaceAlias $nom_carte_reseau
	$Profile_carte.NetworkCategory = "Private"

	Set-NetConnectionProfile -InputObject $Profile_carte 
	}
	
function stocker_password
	{
	$password = "Password123!@#"
	$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force 
	$secureStringText = $secureStringPwd | ConvertFrom-SecureString 
	Set-Content "C:\temp\ExportedPassword.txt" $secureStringText
	$username = "myuser"
	$pwdTxt = Get-Content "C:\temp\ExportedPassword.txt"
	$securePwd = $pwdTxt | ConvertTo-SecureString 
	$credObject = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePwd
	}


	
function get_smb_version
	{
	$hostname = $env:COMPUTERNAME
	$nom_fichier = $hostname+".txt"
	$dir = dir \\localhost\c$
	$version_smb = (get-smbconnection -servername LOCALHOST).dialect | Select-Object -Unique
	Write-Output "$hostname|$version_smb" | Out-File "\\myserver\mypath\$nom_fichier"
	}
function lister_session_rdp
{
	param(
	$nom_machine,
	$login_utilisateur
	)
	
	quser /server:$nom_machine 2>&1 | Select-Object -Skip 1 | ForEach-Object {
        $CurrentLine = $_.Trim() -Replace '\s+',' ' -Split '\s'

        $HashProps = @{
            UserName = $CurrentLine[0]
            ComputerName = $nom_machine
        	}
		if (($CurrentLine[0] -eq $login_utilisateur) -and ($CurrentLine[2] -ne "disc") -and ($CurrentLine[2] -ne "déco"))
		{
		 	$HashProps.SessionName = $CurrentLine[1]
            $HashProps.Id = $CurrentLine[2]
            $HashProps.State = $CurrentLine[3]
            $HashProps.IdleTime = $CurrentLine[4]
            $HashProps.LogonTime = $CurrentLine[5..($CurrentLine.GetUpperBound(0))] -join ' '
			 New-Object -TypeName PSCustomObject -Property $HashProps |
        Select-Object -Property UserName,ComputerName,SessionName,Id,State,IdleTime,LogonTime,Error
		}
		else
		{
	        # If session is disconnected different fields will be selected
#	        if ($CurrentLine[2] -eq 'Disc') 
#			{
#                $HashProps.SessionName = $null
#                $HashProps.Id = $CurrentLine[1]
#                $HashProps.State = $CurrentLine[2]
#                $HashProps.IdleTime = $CurrentLine[3]
#                $HashProps.LogonTime = $CurrentLine[4..6] -join ' '
#                $HashProps.LogonTime = $CurrentLine[4..($CurrentLine.GetUpperBound(0))] -join ' '
#	        } 
#			else 
#			{
#                $HashProps.SessionName = $CurrentLine[1]
#                $HashProps.Id = $CurrentLine[2]
#                $HashProps.State = $CurrentLine[3]
#                $HashProps.IdleTime = $CurrentLine[4]
#                $HashProps.LogonTime = $CurrentLine[5..($CurrentLine.GetUpperBound(0))] -join ' '
#	        }
		}

       
    }
}

function fermer_session_rdp 
{
	param(
	$nom_machine,
	$Id_session
	)
	Write-Host "Fermeture de la session $Id_session "
	rwinsta $Id_session /server:$nom_machine
                   
}						   
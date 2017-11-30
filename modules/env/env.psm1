<#
    .SYNOPSIS
    Module d'intéraction avec les variables d'environnement
    
    .DESCRIPTION
    Ce module regroupe toutes les fonctions supplémentaires d'intéraction avec les variables d'environnement.
	Il permet de stocker dans une variable des infos concernant un utilisateur.
        
    .LINK
     
    .NOTE
    Auteur: Grégory DAVID (gregory.david@sncf.fr)       
#>

function get_env_user
	{
	param($login_utilisateur)	
	$env_user = @()	
	$obj = New-Object Psobject	
	if (!($login_utilisateur))
		{
		$utilisateur_connecte = [Environment]::UserName
		}
	else
		{
		$utilisateur_connecte = $login_utilisateur
		}
	
	$infos_ad_utilisateur_connecte = Get-ADUser $utilisateur_connecte -Properties *
	$cp_utilisateur_connecte = $infos_ad_utilisateur_connecte.samaccountname
	$nom_utilisateur_connecte = $infos_ad_utilisateur_connecte.displayname
	$prenom_utilisateur_connecte = $infos_ad_utilisateur_connecte.givenname
	$nom_famille_utilisateur_connecte = $infos_ad_utilisateur_connecte.surname
	$description_utilisateur_connecte = $infos_ad_utilisateur_connecte.description	
	$nom_2_utilisateur_connecte = $infos_ad_utilisateur_connecte.name	
	$mail_utilisateur_connecte = $infos_ad_utilisateur_connecte.mail	
	$obj | Add-Member -Name "Logonname" -MemberType NoteProperty -Value $cp_utilisateur_connecte
	$obj | Add-Member -Name "displayname" -MemberType NoteProperty -Value $nom_utilisateur_connecte
	$obj | Add-Member -Name "firstname" -MemberType NoteProperty -Value $prenom_utilisateur_connecte
	$obj | Add-Member -Name "lastname" -MemberType NoteProperty -Value $nom_famille_utilisateur_connecte
	$obj | Add-Member -Name "description" -MemberType NoteProperty -Value $description_utilisateur_connecte
	$obj | Add-Member -Name "name" -MemberType NoteProperty -Value $nom_2_utilisateur_connecte
	$obj | Add-Member -Name "mail" -MemberType NoteProperty -Value $mail_utilisateur_connecte
	$env_user += $obj
	Write-Output $env_user
	}

function get_env_computer
	{
	param($nom_machine)
	$env_computer = @()
	$obj = New-Object Psobject	
	if (!($nom_machine))
		{
		$machine = [Environment]::MachineName
		}
	else
		{
		$machine = $nom_machine
		}
	$infos_ad_machine = Get-ADComputer $machine -Properties *
	$nom_machine = $infos_ad_machine.Name
	$description_machine = $infos_ad_machine.description
	$infos_OS_machine = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $nom_machine
	$nom_OS_machine = $infos_OS_machine.caption
	$architecture_os_machine = $infos_OS_machine.osarchitecture
	$ou_machine = $infos_ad_machine.canonicalname
	$ou_machine = $ou_machine.replace("/$nom_machine","")
	$samaccountname_machine = $infos_ad_machine.samaccountname
#	$ou_machine = ($ou_machine -creplace '(?s)^.*/', '').tolower()	
	$obj | Add-Member -Name "Nom" -MemberType NoteProperty -Value $nom_machine
	$obj | Add-Member -Name "Name" -MemberType NoteProperty -Value $nom_machine
	$obj | Add-Member -Name "description" -MemberType NoteProperty -Value $description_machine
	$obj | Add-Member -Name "Nom_os" -MemberType NoteProperty -Value $nom_OS_machine
	$obj | Add-Member -Name "Archi_os" -MemberType NoteProperty -Value $architecture_os_machine
	$obj | Add-Member -Name "OU" -MemberType NoteProperty -Value $ou_machine
	$obj | Add-Member -Name "Samaccountname" -MemberType NoteProperty -Value $samaccountname_machine
	$env_computer += $obj
	Write-Output $env_computer
	}

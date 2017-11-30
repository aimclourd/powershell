<#
    .SYNOPSIS
    Module d'intéraction avec une base de données SQL Server
    
    .DESCRIPTION
    Ce module regroupe toutes les fonctions supplémentaires d'intéraction avec une base de données SQL Server.
	        
    .LINK
     
    .NOTE
    Auteur: Grégory DAVID (gregory.david@sncf.fr)       
#>

function ouvrir_connexion_sqlserver
	{
	param(
	[string]$serveur_sqlserver,
	[string]$user_sqlserver,
	[string]$password_user_sqlserver,
	[string]$database_sqlserver,
	[string]$mode_connexion,
	[string]$verbose
	)
	Write-Host "$serveur_sqlserver $user_sqlserver $password_user_sqlserver $database_sqlserver"
	#Write-Host "server=$serveur_mysql;port=$port_mysql;uid=$user_mysql;pwd=$password_user_mysql;database=$database_mysql;Pooling=False"
	if ($verbose -eq $true)
		{
		Write-Host "Connexion au serveur $serveur_sqlserver"
		}
	if ($mode_connexion -and $mode_connexion -eq "AD")
		{
		$connectionString_sqlserver = "Server=$serveur_sqlserver;Database=$database_sqlserver;Integrated Security=True;"
		}
	else
		{
		$connectionString_sqlserver = "Server=$serveur_sqlserver;uid=$user_sqlserver; pwd=$password_user_sqlserver;Database=$database_sqlserver;Integrated Security=False;"
		}
	$global:connexion_sqlserver = New-Object System.Data.SqlClient.SqlConnection
	$global:connexion_sqlserver.ConnectionString = $connectionString_sqlserver
	$global:connexion_sqlserver.Open()
	$global:connexion_sqlserver	
	}
	
function fermer_connexion_sqlserver
	{
	param(
	$connexion_sqlserver)
	Write-Host "Déconnexion au serveur"
	$global:connexion_sqlserver.Close()
	}
	
function executer_requete_sqlserver
	{
	param([string]$requete_sqlserver,
	$connexion_sqlserver)
	#write-host $global:connexion_sqlserver.state  -BackgroundColor:green
	#$global:connexion_sqlserver = ouvrir_connexion_sqlserver -serveur_sqlserver $serveur_sqlserver -user_sqlserver $user_sqlserver -password_user_sqlserver $password_user_sqlserver -database_sqlserver $database_sqlserver -verbose $true
	if (($global:connexion_sqlserver) -and ($global:connexion_sqlserver.state -eq "open"))
		{
		$global:connexion_sqlserver.close()
		}
	#write-host $global:connexion_sqlserver.state  -BackgroundColor:green
	if (($global:connexion_sqlserver) -and ($global:connexion_sqlserver.state -ne "Open"))
		{
		$global:connexion_sqlserver.open()
		}
	#write-host $global:connexion_sqlserver.state  -BackgroundColor:green
#	if ($champs_sqlserver)
#		{
#		if ($champs_sqlserver -like "*|*")
#			{
#			$liste_champs = $champs_sqlserver.split("|")
#			}
#		else
#			{
#			$liste_champs = $champs_sqlserver
#			}
#		}
	$command = $global:connexion_sqlserver.CreateCommand()
	$command.CommandText = $requete_sqlserver
	$resultat_requete_sqlserver = $command.ExecuteReader()
	$nb_colonnes = $resultat_requete_sqlserver.FieldCount
	$results = @()
	$ligne = ""
	$i=0
	while ($resultat_requete_sqlserver.read())
		{
			$j=0
			$obj = New-Object Psobject
			while ($j -lt $nb_colonnes)
				{
				$nom_ligne = $resultat_requete_sqlserver.GetName($j)
				$valeur_ligne = $resultat_requete_sqlserver.GetValue($j)
				$obj | Add-Member -Name "$nom_ligne" -MemberType NoteProperty -Value $valeur_ligne
		
				$j++
				}
			$ligne = supprimer_dernier_caractere $ligne
			$results += $obj
		}
		write-output $results
	$global:connexion_sqlserver.close()
	}
	
function generer_requete_inventaire
	{
	param($liste_serveurs,
	$nom_table,
	$nom_champs)
	$serveurs = Get-Content $liste_serveurs
	$requete = "SELECT * FROM $nom_table WHERE"
	$i=0
	foreach ($serveur in $serveurs)	
		{
		if ($i -lt "1")
			{
			$requete += "`n $nom_champs LIKE '$serveur%'"
			}
		else
			{
			$requete += "`n OR $nom_champs LIKE '$serveur%'"
			}
		$i++
		}
	$requete = $requete -replace("WHERE OR","WHERE")
	write-output $requete
	
	}
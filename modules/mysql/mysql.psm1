<#
    .SYNOPSIS
    Module d'intéraction avec une base de données MySQL
    
    .DESCRIPTION
    Ce module regroupe toutes les fonctions supplémentaires d'intéraction avec une base de données MySQL.
	        
    .LINK
     
    .NOTE
    Auteur: Grégory DAVID (gregory.david@sncf.fr)       
#>

function ouvrir_connexion_mysql
	{
	param(
	[string]$serveur_mysql,
	[string]$port_mysql,
	[string]$user_mysql,
	[string]$password_user_mysql,
	[string]$database_mysql,
	[string]$verbose
	)
	#Write-Host "$serveur_mysql $port_mysql $user_mysql $password_user_mysql $database_mysql"
	#Write-Host "server=$serveur_mysql;port=$port_mysql;uid=$user_mysql;pwd=$password_user_mysql;database=$database_mysql;Pooling=False"
	if ($verbose -eq $true)
		{
		Write-Host "Connexion au serveur $serveur_mysql"
		}
	[void][system.reflection.Assembly]::LoadWithPartialName("MySql.Data")
	$global:connexion_mysql = New-Object MySql.Data.MySqlClient.MySqlconnection("server=$serveur_mysql;port=$port_mysql;uid=$user_mysql;pwd=$password_user_mysql; database=$database;Pooling=False") 
	$global:connexion_mysql.Open()
	$global:connexion_mysql
	}
	
function fermer_connexion_mysql
	{
	param(
	$connexion_mysql)
	Write-Host "Déconnexion au serveur"
	$global:connexion_mysql.Close()
	}
	
function requete_mysql
	{
	param(
	[string]$serveur_mysql,
	[string]$port_mysql,
	[string]$user_mysql,
	[string]$password_user_mysql,
	[string]$database_mysql,
	[string]$requete_mysql,
	[string]$type_requete,
	[string]$nom_donnee,
	[string]$verbose
	)	
	if ($verbose -eq $true)
		{
		Write-Host "Exécution de la requete $requete_mysql"
		}
	$resultats = ""
	$requete_mysql = "USE $database_mysql;" + $requete_mysql
	$resultats_execution_commande_mysql = New-Object "System.Data.DataTable"
	$commande_mysql = New-Object Mysql.Data.MysqlClient.MySqlCommand
	$commande_mysql.connection = $connexion_mysql
	$commande_mysql.commandtext = $requete_mysql
	$execution_commande_mysql = $commande_mysql.executereader()

	if ($type_requete -and ($type_requete -eq "SELECT"))
		{
		$resultats_execution_commande_mysql.load($execution_commande_mysql)
		$execution_commande_mysql.dispose()	
		$infos_nb_resultats = $resultats_execution_commande_mysql | Measure-Object
		$nb_resultats = $infos_nb_resultats.count
		if ($nb_resultats -eq 0)
			{
			Write-Output "Pas de données"
			}
		if ($nb_resultats -eq 1)
			{
			Write-Output $resultats_execution_commande_mysql.password
			}
		if ($nb_resultats -gt 1)
			{
			Write-Output $resultats_execution_commande_mysql
	#		foreach ($resultat in $resultats_execution_commande_mysql)
	#			{
	#			Write-Output $resultat.$nom_donnee
	#			}
			}
		}
	$execution_commande_mysql.dispose()	
	}
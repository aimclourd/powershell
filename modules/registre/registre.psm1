<#
    .SYNOPSIS
    Module d'intéraction avec la base de registre
    
    .DESCRIPTION
    Ce module regroupe toutes les fonctions supplémentaires d'intéraction avec la base de registre d'une machine.	 
    .LINK
     
    .NOTE
    Auteur: Grégory DAVID (gregory.david@sncf.fr)       
#>

function connexion_registre
	{
	param($nom_machine,
	$nom_ruche)
	$global:RegProv = ""
	#Registry Hives
	[long]$HIVE_HKROOT = 2147483648
	[long]$HIVE_HKCU = 2147483649
	[long]$HIVE_HKLM = 2147483650
	[long]$HIVE_HKU = 2147483651
	[long]$HIVE_HKCC = 2147483653
	[long]$HIVE_HKDD = 2147483654

	# Value Data Types
	[int]$REG_SZ = 1
	[int]$REG_EXPAND_SZ = 2
	[int]$REG_BINARY = 3
	[int]$REG_DWORD = 4
	[int]$REG_MULTI_SZ = 7
	[int]$REG_QWORD = 11
	
	if ($nom_ruche)
		{
		$global:ID_Ruche = recuperer_id_ruche -nom_ruche $nom_ruche
		$global:ID_Ruche = [convert]::ToInt64($global:ID_Ruche,10)
		}
	# Get Regeirty Provider
	if ($nom_machine) {
	  # Remote Computer
	  $global:RegProv = [WMIClass]$("\\$nom_machine\root\Default:StdRegProv") 
	} else {
	  # Local Computer
	  $global:RegProv = [WMIClass]"root\Default:StdRegProv"
	}
	}

function recuperer_id_ruche
	{
	param($nom_ruche)	
	switch ($ruche) 
   		{ 
        HKLM {"2147483650"} 
        HKROOT {"2147483648"} 
        HKCU {"2147483649"} 
        HKU {"2147483651"} 
        HKCC {"2147483653"} 
        HKDD {"2147483654"}         
        default {"This value is not recognized"}
    	}
	}
	
function lire_cle_registre
	{
	param($nom_machine,$ruche,$chemin)
	connexion_registre -nom_machine $nom_machine -nom_ruche $ruche
	# Enumerate Keys
	$ReturnedInfo = $global:RegProv.EnumKey($global:id_ruche, $chemin)
	$ReturnedInfo | foreach { write-output $_.sNames }
	}

function creer_cle_registre
	{	
	param($nom_machine,$nom_ruche,$chemin,$cle)
	connexion_registre -nom_machine $nom_machine -nom_ruche $nom_ruche
	# Enumerate Keys
#	$ReturnedInfo = $global:RegProv.EnumKey($nom_ruche, $chemin)
#	$ReturnedInfo | foreach { write-output $_.sNames }
	$chemin_complet = $chemin+"\"+$cle
	$ReturnedInfo = $RegProv.CreateKey($ID_Ruche, $chemin_complet)
	if ($ReturnedInfo.Returnvalue -eq "0")
		{Write-Output "Clé $cle créée"}
	}
	
function supprimer_cle_registre
	{	
	param($nom_machine,$nom_ruche,$chemin,$cle)
	connexion_registre -nom_machine $nom_machine -nom_ruche $nom_ruche	
	# Enumerate Keys
	$chemin_complet = $chemin+"\"+$cle
	$ReturnedInfo = $RegProv.DeleteKey($ID_Ruche, $chemin_complet)
	if ($ReturnedInfo.Returnvalue -eq "0")
		{Write-Output "Clé $cle supprimée"}
	}

function supprimer_valeur_cle_registre
	{	
	param($nom_machine,$nom_ruche,$chemin,$cle,$valeur)
	connexion_registre -nom_machine $nom_machine -nom_ruche $nom_ruche	
	# Enumerate Keys
	$chemin_complet = $chemin+"\"+$cle
	$ReturnedInfo = $RegProv.DeleteValue($ID_Ruche, $chemin_complet, $valeur)
	if ($ReturnedInfo.Returnvalue -eq "0")
		{Write-Output "Valeur $valeur supprimée"}
	}
	
function lire_valeur_cle_registre
	{
	param($nom_machine,$ruche,$chemin)
	connexion_registre -nom_machine $nom_machine -nom_ruche $ruche	
	#$global:ID_ruche = recuperer_id_ruche -nom_ruche $ruche
	# Enumerate Keys
	#$chemin_cle = $chemin+"\"+$cle		
	$ReturnedInfo = $global:RegProv.EnumValues($ID_Ruche, $chemin)	
	$liste_cles = @()		
	$valeurs = $ReturnedInfo.sNames	
	$types = $ReturnedInfo.Types	
	$i=0	
	while ($i -lt $valeurs.count)
		{
		$info_valeur = $valeurs[$i]
		$type_valeur = $types[$i]
		$valeur_cle = ""
		if ($type_valeur -eq "1")
			{
			$nom_type = "String"
			$valeur_cle = lire_valeurstring_cle_registre -chemin $chemin -cle $info_valeur -nom_machine $nom_machine -ruche $ID_Ruche
			}
		if ($type_valeur -eq "2")
			{
			$nom_type = "ExpandedString"
			$valeur_cle = lire_valeurexpandedstring_cle_registre -chemin $chemin -cle $info_valeur -nom_machine $nom_machine -ruche $ID_Ruche
			}
		if ($type_valeur -eq "3")
			{
			$nom_type = "Binary"
			$valeur_cle = lire_valeurbinaire_cle_registre -chemin $chemin -cle $info_valeur -nom_machine $nom_machine -ruche $ID_Ruche
			}
		if ($type_valeur -eq "4")
			{
			$nom_type = "DWord"
			$valeur_cle = lire_valeurdword_cle_registre -chemin $chemin -cle $info_valeur -nom_machine $nom_machine -ruche $ID_Ruche
			}
		if ($type_valeur -eq "7")
			{
			$nom_type = "MultiString"
			$valeur_cle = lire_valeurmultistring_cle_registre -chemin $chemin -cle $info_valeur -nom_machine $nom_machine -ruche $ID_Ruche
			}
		$objet_cles = New-Object Psobject
		$objet_cles | Add-Member -Name "Cle" -MemberType NoteProperty -Value $info_valeur  
		$objet_cles | Add-Member -Name "Valeur" -MemberType NoteProperty -Value $valeur_cle 
		$objet_cles | Add-Member -Name "ID_Type" -MemberType NoteProperty -Value $type_valeur 
		$objet_cles | Add-Member -Name "Nom_Type" -MemberType NoteProperty -Value $nom_type 
		
		$liste_cles += $objet_cles
		$i++
		}
		Write-Output $liste_cles
#	foreach ($cle in $liste_cles)
#		{
#		$nom_cle = $cle.cle
#		$valeur_cle = $cle.valeur
#		$ID_Type_cle = $cle.ID_Type
#		$Nom_Type_cle = $cle.Nom_Type
#		Write-Output "$nom_cle|$valeur_cle|$ID_Type_cle|$Nom_Type_cle"
#		}
	}
	
function lire_valeurbinaire_cle_registre
	{
	param($nom_machine,$ruche,$chemin,$cle)
#	if (!($global:id_ruche))
#		{
#		connexion_registre -nom_machine $nom_machine -nom_ruche $ruche	
#		}
	# Enumerate Keys
	#$chemin_cle = $chemin+"\"+$cle	
	$ReturnedInfo = ""
	$ReturnedInfo = $global:RegProv.GetBinaryValue($ID_ruche, $chemin, $cle)
	$ReturnedInfo | foreach { write-output $_.uvalue }
	}

function ecrire_valeurbinaire_cle_registre
	{
	param($nom_machine,$ruche,$chemin,$cle,$valeur,$afficher_resultat)
#	if (!($global:id_ruche))
#		{
#		connexion_registre -nom_machine $nom_machine -nom_ruche $ruche	
#		}	
	# Enumerate Keys
	#$chemin_cle = $chemin+"\"+$cle	
	$ReturnedInfo = ""
	$ReturnedInfo = $global:RegProv.SetBinaryValue($ID_ruche, $chemin, $cle, $valeur)
	if (($afficher_resultat) -and ($ReturnedInfo.Returnvalue -eq "0"))
		{Write-Output "Ecriture de la valeur $valeur pour la clé $cle effectuée"}
	if ($ReturnedInfo.Returnvalue -ne "0")
		{Write-Output "Erreur lors de l'écriture de la valeur $valeur pour la clé $cle"}
	}	
	
function lire_valeurdword_cle_registre
	{
	param($nom_machine,$ruche,$chemin,$cle)
#	if (!($global:id_ruche))
#		{
#		connexion_registre -nom_machine $nom_machine -nom_ruche $ruche	
#		}
	# Enumerate Keys
	#$chemin_cle = $chemin+"\"+$cle	
	$ReturnedInfo = ""
	$ReturnedInfo = $global:RegProv.GetDWORDValue($ID_ruche, $chemin, $cle)
	$ReturnedInfo | foreach { write-output $_.uvalue }
	}

function ecrire_valeurdword_cle_registre
	{
	param($nom_machine,$ruche,$chemin,$cle,$valeur,$afficher_resultat)
#	if (!($global:id_ruche))
#		{
#		connexion_registre -nom_machine $nom_machine -nom_ruche $ruche	
#		}
	# Enumerate Keys
	#$chemin_cle = $chemin+"\"+$cle	
	$ReturnedInfo = ""
	$ReturnedInfo = $global:RegProv.SetDWORDValue($ID_ruche, $chemin, $cle, $valeur)
	if (($afficher_resultat) -and ($ReturnedInfo.Returnvalue -eq "0"))
		{Write-Output "Ecriture de la valeur $valeur pour la clé $cle effectuée"}
	if ($ReturnedInfo.Returnvalue -ne "0")
		{Write-Output "Erreur lors de l'écriture de la valeur $valeur pour la clé $cle"}
	}

function lire_valeurqword_cle_registre
	{
	param($nom_machine,$ruche,$chemin,$cle)
#	if (!($global:id_ruche))
#		{
#		connexion_registre -nom_machine $nom_machine -nom_ruche $ruche	
#		}
	# Enumerate Keys
	#$chemin_cle = $chemin+"\"+$cle
	$ReturnedInfo = ""
	$ReturnedInfo = $global:RegProv.GetQWORDValue($ID_ruche, $chemin, $cle)
	$ReturnedInfo | foreach { write-output $_.uvalue }
	}

function ecrire_valeurqword_cle_registre
	{
	param($nom_machine,$ruche,$chemin,$cle, $valeur,$afficher_resultat)
#	if (!($global:id_ruche))
#		{
#		connexion_registre -nom_machine $nom_machine -nom_ruche $ruche	
#		}	
	# Enumerate Keys
	#$chemin_cle = $chemin+"\"+$cle	
	$ReturnedInfo = ""
	$ReturnedInfo = $global:RegProv.SetQWORDValue($ID_ruche, $chemin, $cle, $valeur)	
	if (($afficher_resultat) -and ($ReturnedInfo.Returnvalue -eq "0"))
		{Write-Output "Ecriture de la valeur $valeur pour la clé $cle effectuée"}
	if ($ReturnedInfo.Returnvalue -ne "0")
		{Write-Output "Erreur lors de l'écriture de la valeur $valeur pour la clé $cle"}
	}

function lire_valeurexpandedstring_cle_registre
	{
	param($nom_machine,$ruche,$chemin,$cle)
	
	# Enumerate Keys
	#$chemin_cle = $chemin+"\"+$cle	
	$ReturnedInfo = ""
	$ReturnedInfo = $global:RegProv.GetExpandedStringValue($ID_ruche, $chemin, $cle)
	$ReturnedInfo | foreach { write-output $_.svalue }
	}

function ecrire_valeurexpandedstring_cle_registre
	{
	param($nom_machine,$ruche,$chemin,$cle,$valeur,$afficher_resultat)
#	if (!($global:id_ruche))
#		{
#		connexion_registre -nom_machine $nom_machine -nom_ruche $ruche	
#		}
	# Enumerate Keys
	#$chemin_cle = $chemin+"\"+$cle	
	$ReturnedInfo = ""
	$ReturnedInfo = $global:RegProv.SetExpandedStringValue($ID_ruche, $chemin, $cle, $valeur)
	if (($afficher_resultat) -and ($ReturnedInfo.Returnvalue -eq "0"))
		{Write-Output "Ecriture de la valeur $valeur pour la clé $cle effectuée"}
	if ($ReturnedInfo.Returnvalue -ne "0")
		{Write-Output "Erreur lors de l'écriture de la valeur $valeur pour la clé $cle"}
	}

function lire_valeurmultistring_cle_registre
	{
	param($nom_machine,$ruche,$chemin,$cle)
#	if (!($global:id_ruche))
#		{
#		connexion_registre -nom_machine $nom_machine -nom_ruche $ruche	
#		}
	# Enumerate Keys
	#$chemin_cle = $chemin+"\"+$cle	
	$ReturnedInfo = ""
	$ReturnedInfo = $global:RegProv.GetMultiStringValue($ID_ruche, $chemin, $cle)
	$ReturnedInfo | foreach { write-output $_.svalue }
	}

function ecrire_valeurmultistring_cle_registre
	{
	param($nom_machine,$ruche,$chemin,$cle, $valeur,$afficher_resultat)
#	if (!($global:id_ruche))
#		{
#		connexion_registre -nom_machine $nom_machine -nom_ruche $ruche	
#		}
	# Enumerate Keys
	#$chemin_cle = $chemin+"\"+$cle	
	$ReturnedInfo = ""
	$ReturnedInfo = $global:RegProv.SetMultiStringValue($ID_ruche, $chemin, $cle, $valeur)
	if (($afficher_resultat) -and ($ReturnedInfo.Returnvalue -eq "0"))
		{Write-Output "Ecriture de la valeur $valeur pour la clé $cle effectuée"}
	if ($ReturnedInfo.Returnvalue -ne "0")
		{Write-Output "Erreur lors de l'écriture de la valeur $valeur pour la clé $cle"}
	}

function lire_valeurstring_cle_registre
	{
	param($nom_machine,$ruche,$chemin,$cle)
	if ($ruche -notlike "*2*")
		{
		$global:ID_ruche = recuperer_id_ruche -nom_ruche $ruche
		connexion_registre -nom_machine $nom_machine -nom_ruche $ruche	
		}
	# Enumerate Keys
	#$chemin_cle = $chemin+"\"+$cle	
	$ReturnedInfo = ""
	$ReturnedInfo = $global:RegProv.GetStringValue($ID_ruche, $chemin, $cle)
	$ReturnedInfo | foreach { write-output $_.svalue }
	}
	
function ecrire_valeurstring_cle_registre
	{
	param($nom_machine,$ruche,$chemin,$cle, $valeur,$afficher_resultat)
	#connexion_registre -nom_machine $nom_machine -nom_ruche $ruche		
	# Enumerate Keys
	#$chemin_cle = $chemin+"\"+$cle	
	if ($ruche -notlike "*2*")
		{
		$global:ID_ruche = recuperer_id_ruche -nom_ruche $ruche
		connexion_registre -nom_machine $nom_machine -nom_ruche $ruche	
		}
	$ReturnedInfo = $global:RegProv.SetStringValue($ID_ruche, $chemin, $cle, $valeur)
	if (($afficher_resultat) -and ($ReturnedInfo.Returnvalue -eq "0"))
		{Write-Output "Ecriture de la valeur $valeur pour la clé $cle effectuée"}
	if ($ReturnedInfo.Returnvalue -ne "0")
		{Write-Output "Erreur lors de l'écriture de la valeur $valeur pour la clé $cle"}
	}	
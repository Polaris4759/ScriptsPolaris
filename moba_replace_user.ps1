# Ce script permet de remplacer l'utilisateur défini pour les sessions sauvegardées par un autre
# Il récupère l'utilisateur défini dans la première sessions, de type "eNUMERO"
# Il récupère ce numéro, l'indique à l'utilisateur, et lui demande un autre numéro
# Ce dernier numéro est remplacé par celui entré par l'utilisateur

Clear-Host

# Récupération de l'espace disponible du disque
$size = ((Get-Volume -DriveLetter U).SizeRemaining)/1MB
#Conversion en MB
#$size = $size/1MB

# Récupération de l'espace requis
$sizeneeded = ((Get-ChildItem . | Measure-Object Length -s).Sum)/1KB

# Si la taille disponible est supérieure à la taille requise, copie du dossier vers le dossier Document
if ($size -gt $sizeneeded){
    Copy-Item . -Destination %HOMESHARE%/Documents
}else{
    Write-Host "Il n'y a pas assez de place sur le U. Merci de faire de la place et de relancer le script."
    pause
    exit
}

Set-Location "%HOMESHARE%/Documents"

# Récupération des lignes contenant les caractères "%%"
echo "Récupération du fichier Sessions"
$file = Get-Content -Path ".\MobaXterm Sessions.mxtsessions"
foreach ($line in $file){if ($line -like "*%%*") {$line | out-file -FilePath .\moba2.txt -Append}}

# Remplacement de chaque "%" par des retours à la ligne
Write-host -nonewline "Récupération du e."
(Get-Content -Path .\temp1.txt | Select-Object -First 1) -replace '%',"`r`n" | Set-Content -Path .\temp2.txt

# Récupération des lignes commençant par "e", et affectation dans une variable
Write-host -nonewline "."
foreach ($line in (Get-Content -Path .\temp2.txt)) {if ($line.StartsWith('e')){$line2=$line}}

# Retrait du "e" dans la variable
Write-host -nonewline "."
$olduser=($line2 -replace 'e','')

# Prompt du nouvel utilisateur
Write-Output "Le logon suivant va être remplacé : $olduser"
$User=Read-Host -Prompt "Quel logon mettre à la place ?"

# Remplacement de l'utilisateur dans le fichier de configuration
(Get-Content -Path ".\MobaXterm Sessions.mxtsessions" -Raw) -replace $olduser,$User | Set-Content -Path ".\MobaXterm Sessions.mxtsessions"

# Suppression des fichiers temporaires
Remove-Item -Path .\temp1.txt
Remove-Item -Path .\temp2.txt

# FIN DE SCRIPT
Read-Host -Prompt "Fin du script"
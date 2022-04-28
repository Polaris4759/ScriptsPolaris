# Ce script permet de remplacer l'utilisateur défini pour les sessions sauvegardées par un autre
# Il récupère l'utilisateur défini dans la première sessions, de type "eNUMERO"
# Il récupère ce numéro, l'indique à l'utilisateur, et lui demande un autre numéro
# Ce dernier numéro est remplacé par celui entré par l'utilisateur

Clear

# Récupération des lignes contenant les caractères "%%"
$file = Get-Content .\moba.txt

foreach ($line in $file){if ($line -like "*%%*") {$line | out-file -FilePath .\moba2.txt -Append}}

# Remplacement de chaque "%" par des retours à la ligne
(Get-Content .\moba2.txt | Select -First 1) -replace '%',"`r`n" | Set-Content -Path moba3.txt

# Récupération des lignes commençant par "e", et affectation dans une variable
foreach ($line in (Get-Content -Path .\moba3.txt)) {if ($line.StartsWith('e')){$line2=$line}}

# Retrait du "e" dans la variable
$olduser=($line2 -replace 'e','')

# Prompt du nouvel utilisateur
echo "Le logon suivant va être remplacé : $olduser"
$User=Read-Host -Prompt "Quel logon mettre à la place ?"

# Remplacement de l'utilisateur dans le fichier de configuration
(Get-Content -Path .\moba.txt -Raw) -replace $olduser,$User | set-content -Path .\moba.txt

# Suppression des fichiers temporaires
Remove-Item -Path .\moba2.txt
Remove-Item -Path .\moba3.txt
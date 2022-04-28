#!/bin/bash

#######################################
# Script créé le : 15/01/2022 à 18:31 #
#######################################

###############
# DESCRIPTION #
###############

# Ce script modifie la taille d'une vidéo en changeant la résolution ainsi que le bitrate

# Commande de conversion :
#ffmpeg -i "<input>" -vf "scale=1280:720" -b:v 2M "<output>"

#############
# VARIABLES #
#############


chscript=$(dirname $(readlink -f $0))
namescript=`basename "$(realpath $0)"`

# COULEURS
blue="\e[36m"
red="\e[31m"
green="\e[32m"
orange="\e[33m"
def="\e[0m"

# VARIABLES UTILISEES DANS LE SCRIPT
debug=0
timestamp=$(date +"%Y%m%d")
com="commandes.txt"

#################
# VERIFICATIONS #
#################



############
# FONCTION #
############

usage(){

echo "
Ce script permet de réduire la taille d'une vidéo en utilisant ffmpeg.
Il récupère la liste des vidéos dans un fichier qu'il faut mettre en entrée.
Il génère un fichier commandes qui contient les commandes ffmpeg a exécuter, qu'il existe ensuite : \"bash commandes\"
Une fois la conversion terminé, il envoie un mail.

Options :
 - f : Fichier contenant la liste des chemins des vidéos à modifier
 - r : Résolution souhaitée
 - b : Bitrate souhaité (Valeur uniquement - exemple : 2 pour 2Mb/s)
 - d : Debug
 - m : Spécifie un dossier où déplacer les vidéos avant la conversion
 Ce chemin doit être absolu, commencer par un /, et se terminer par un /.

 Résolutions possibles :
 480  : 854x480
 v480 : 480x854
 720  : 1280x720
 1080 : 1920x1080

 Exemple :
 movieconverter.sh -f liste.txt -b 2 -r 720 -m /home/toto/videos/reduced/
 "

exit 1

}

##########
# SCRIPT #
##########


while getopts ":b:df:hm:r:" option
#Avec les deux points en début de ligne, l'erreur ne s'affichera pas dans le terminal
#Avec les deux points après une des options, cela indique que cette option requiert un argument
do
        case $option in
                #Choix du bitrate
                b)
                bitrate=$OPTARG
                ;;
                #Mode Debug
                d)
                debug=1
                ;;
                #Fichier contenant la liste des chemins de vidéos à convertir
                f)
                fichier=$OPTARG
                ;;
                #Help / Usage
                h)
                usage
                ;;
                #Choix du dossier de destination
                m)
                move=$OPTARG
                ;;
                #Choix de la résolution
                r)
                res=$OPTARG
                ;;
                #Le cas suivant permet de faire certaines actions si l'option est invalide
                \?)
                echo "$OPTARG : option invalide"
                exit 1
                ;;
                #Le cas suivant (:) permet de faire certaines actions si l'option requiert un argument mais que ce dernier est manquant
                :)
                echo "L'option $OPTARG requiert un argument"
                exit 1
                ;;
        esac
done

#Valorisation des variables (largeur et hauteur) en fonction de la résolution choisie
case $res in
        480)
        larg=854
        haut=480
        ;;
        v480)
        larg=480
        haut=854
        ;;
        720)
        larg=1280
        haut=720
        ;;
        1080)
        larg=1920
        haut=1080
        ;;
esac

#Si le fichier n'est pas spécifié ni la résolution voulue ou le bitrate voulue, on affiche l'usage
if [ -z $fichier ];then echo -e "${red}Un fichier en entrée doit être spécifié.${def}";usage;fi
if [ -z $haut ] || [ -z $bitrate ];then echo -e "${red}Il faut spécifié une résolution valide ET un bitrate.${def}";usage;fi

if [ $move ];then
        if [[ ! $move =~ ^/ ]];then echo "Il faut mettre un chemin absolu. Faire un pwd";exit 2;fi
        if [[ ! $move =~ /$ ]];then echo "Il faut mettre un slash à la fin du chemin";exit 3;fi
        if [ ! -e $move ];then echo -e "${red}Le chemin $move est introuvable${def}";exit 4;fi
fi

#Création d'un fichier mail qui sera utilisé à la fin
echo "<h1>Conversion de vidéo terminée</h1>" >> mail.txt
echo "<p> Début de la conversion : $(date +'%Y-%m-%d_%Hh%Mm%Ss')</p>" >> mail.txt

if [ ! -e $fichier ];then
        echo "Le fichier $fichier n'existe pas."
else
        #Création d'un fichier commandes.txt qui sera utilisé à la fin
        > $com
        cat $fichier | while read line;do
                #Vérification que les vidéos listées existes bien
                if [ ! -e "$line" ];then
                        echo -e "${red}Fichier $line introuvable${def}"
                        continue
                else
                        echo -e "${green}Fichier $line trouvé${def}"
                        chemin=`sed -E 's/(.*\/).*/\1/' <<< "$line"`
                        titre=`sed -E 's/.*\/(.*)\..*/\1/' <<< "$line"`
                        ext=`sed -E 's/.*(\..*)/\1/' <<< "$line"`

                        if [ $move ];then
                                mv "$line" "$move"
                                chemin="${move}"
                        fi


                        #Pas en mode debug, on génère une commande ffmpeg et on l'ajoute dans le fichier commandes.txt
                        if [ $debug -eq 0 ];then
                                echo -ne 'echo -e "<p><strong><span style=\"text-decoration: underline;\">Traitement du fichier :</span></strong>' >> $com
                                echo -ne "${chemin}${titre}${ext}<br/>" >> $com
                                echo 'Heure de traitement : $(date +%Y-%m-%d_%Hh%Mm%S)</p>" >> mail.txt' >> $com
                                echo "ffmpeg -i \"${chemin}${titre}${ext}\" -vf \"scale=$larg:$haut\" -b:v ${bitrate}M \"${chemin}${titre}_${res}p${ext}\" " >> $com
                        fi
                        #En mode debug, on affiche juste dans le terminal
                        if [ $debug -eq 1 ];then
                                echo "ffmpeg -i \"${chemin}${titre}${ext}\" -vf \"scale=$larg:$haut\" -b:v ${bitrate}M \"${chemin}${titre}_${res}${ext}\" "
                        fi
                fi

        done

fi

#Si des fichiers sont à convertir, on traite le fichier commandes.txt, ligne par ligne
if [ $debug -eq 0 ];then
        if [ `cat $com | wc -l` -ne 0 ];then

                bash $com
                echo "<h2>La conversion est terminée. Les fichiers ont été déplacés dans $move</h2>" >> mail.txt
                #Une fois terminé, on envoi un mail pour notifier
                cat mail.txt | mail -a "Content-type: text/html;charset=UTF-8" -s "Conversion vidéos" --append=FROM:"Video Converter <stanryr@gmail.com>" stanislas.rouyer@gmail.com
        else
                echo -e "${red}Le fichier $com est vide${def}"
        fi
fi

#############################
# SUPPRESSION FICHIERS TEMP #
#############################

if [ -e mail.txt ];then rm -f mail.txt;fi
if [ -e $com ];then rm -f $com;fi

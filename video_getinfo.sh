#!/bin/bash

#######################################
# Script créé le : 15/01/2022 à 15:30 #
#######################################

###############
# DESCRIPTION #
###############



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
tempfile="/tmp/getinfo.txt"
outfile="getinfo.csv"
recurs=0
frame=0
qualite=0
langue=0
vff=0
vo=0
eng=0

#################
# VERIFICATIONS #
#################

if [ -e getinfo.csv ];then rm -f getinfo.csv;fi

############
# FONCTION #
############

usage(){

echo "
Ce script permet de récupérer soit : 
 - les informations de résolutions et de bitrate de vidéos.
 - Ou les informations concernant les langues des vidéos selon un format standardisé (VFF ou VO pour les pistes audio, Eng Full pour les pistes de sous-titres).
Il se lance dans le dossier contenant les vidéos, et récupérera les infos de toutes les vidéos.

Options :
 - Q : Récupère les informations concernant la qualité d'image (largeur, hauteur, bitrate, frames)
 - i : Récupère également le nombre total d'images de la vidéo (plus lent)

 - L : Récupère les informations concernant les langues (VFF, VO, sous-titres Eng)
 - f : Vérifie si la VFF est présente
 - o : Vérifie si la VO est présente
 - e : Vérifie si les sous-titres anglais sont présents

 - R : Récursif

Exemples : 
getinfo.sh -Q
    Récupère la qualité vidéo pour les fichiers du dossier courant

getinfo.sh -RLe
    Sort un fichier csv indiquant si les sous-titres anglais sont présent pour les fichiers du dossier courant, et des sous-dossiers
"

exit 1

}

recupInfo(){
        cat liste.txt | while read line;do
                echo -e "${blue}${line}${def}"
                #Récupération des infos de la vidéo dans un fichier temporaire
                ffmpeg -i "$line" > $tempfile 2>&1
                if [ $qualite -eq 1 ];then
                        #Récupération du nombre de frames
                        if [ $frame -eq 1 ];then
                                echo -e "\t${green}Récupération des frames de ${line}${def}"
                                frames=`ffprobe -v error -select_streams v:0 -count_packets -show_entries stream=nb_read_packets -of csv=p=0 "$line"`
                        fi
                        #Valorisation des différentes variables
                        brate=`grep -E "Duration.*start.*bitrate" $tempfile | sed -E 's/.*bitrate: //g' | sed -E 's/ kb\/s//g'`
                        width=`grep -E "Stream.*Video.*fps" $tempfile | sed -E 's/.* ([0-9]*)x[0-9]*.*/\1/g'`
                        height=`grep -E "Stream.*Video.*fps" $tempfile | sed -E 's/.* [0-9]*x([0-9]*).*/\1/g'`
                        info=`grep -E "Stream.*Video.*fps" $tempfile`
                        #Ajout des valeurs dans le fichier csv
                        if [ $frame -eq 1 ];then
                                echo -e "\t${orange}Nombre de frames : ${frames} ${def}"
                                echo "$line;$brate;$width;$height;$frames;$info" >> $outfile
                        else
                                echo "$line;$brate;$width;$height;$info" >> $outfile
                        fi
                fi
                if [ $langue -eq 1 ];then
                        printf "$line" >> $outfile
                        if [ $vff -eq 1 ];then
                                VFFtemp=`grep -c "VFF" $tempfile`
                                if [ $VFFtemp -eq 1 ];then
                                        VFF="Oui"
                                elif [ $VFFtemp -gt 1 ];then
                                        VFF="Plus de 1 correspondance"
                                else
                                        VFF="Non"
                                fi
                                printf ";$VFF" >> $outfile
                        fi
                        if [ $vo -eq 1 ];then
                                VOtemp=`grep -c "VO" $tempfile`
                                if [ $VOtemp -eq 1 ];then
                                        VO="Oui"
                                elif [ $VOtemp -gt 1 ];then
                                        VO="Plus de 1 correspondance"
                                else
                                        VO="Non"
                                fi
                                printf ";$VO" >> $outfile
                        fi
                        if [ $eng -eq 1 ];then
                                ENGtemp=`grep -c "Eng Full" $tempfile`
                                if [ $ENGtemp -eq 1 ];then
                                        ENG="Oui"
                                elif [ $ENGtemp -gt 1 ];then
                                        ENG="Plus de 1 correspondance"
                                else
                                        ENG="Non"
                                fi
                                printf ";$ENG" >> $outfile
                        fi
                        printf "\n" >> $outfile
                fi
        done
}

##########
# SCRIPT #
##########


while getopts ":QiLfoeR" option
#Avec les deux points en début de ligne, l'erreur ne s'affichera pas dans le terminal
do
        case $option in
                Q)
                qualite=1
                ;;
                i)
                frame=1
                ;;
                L)
                langue=1
                ;;
                f)
                vff=1
                ;;
                o)
                vo=1
                ;;
                e)
                eng=1
                ;;
                R)
                recurs=1
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

#Si aucune option choisie
if [ -z $frame ];then usage;fi


#Création du fichier csv de sortie
if [ $recurs -eq 1 ];then
        find . -type f ! -name "*.csv" ! -name "*.txt" > liste.txt
else
        find . -maxdepth 1 -type f ! -name "*.csv" ! -name "*.txt" > liste.txt
fi

if [ $qualite -eq 1 ];then
        if [ $frame -eq 1 ];then
                echo "Récupération des frames"
                echo "Titre;Bitrate;Largeur;Hauteur;Frames;Infos" > $outfile
        else
                echo "Titre;Bitrate;Largeur;Hauteur;Infos" > $outfile
        fi
        recupInfo
elif [ $langue -eq 1 ];then
        printf "Titre" >> $outfile
        if [ $vff -eq 1 ];then printf ";VFF" >> $outfile;fi
        if [ $vo -eq 1 ];then printf ";VO" >> $outfile;fi
        if [ $eng -eq 1 ];then printf ";Eng Subs" >> $outfile;fi
        printf "\n" >> $outfile
        recupInfo
else
        usage
fi



echo "Le fichier $outfile a été généré"

#############################
# SUPPRESSION FICHIERS TEMP #
#############################

if [ -e liste.txt ];then rm -f liste.txt;fi

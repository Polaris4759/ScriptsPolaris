#!/bin/bash

#######################################
# Script créé le : 16/06/2021 à 20:04 #
#######################################

#############
# VARIABLES #
#############

chscript=$(dirname $(readlink -f $0))

# COULEURS
blue="\e[36m"
red="\e[31m"
green="\e[32m"
orange="\e[33m"
def="\e[0m"


#################
# VERIFICATIONS #
#################

verif_nom_sortie(){
        if [ `ls | grep -c -i ${nom_sortie}` -ne 0 ];then
                echo "Le fichier ${nom_sortie} existe déjà"
                nom_sortie=''
        fi
}

verif_fic_entree(){
        if [ ! -e "${fic}" ];then
                echo "Le fichier en entrée n'existe pas"
                fic=''
        fi
}

usage(){
        echo -e "
Il est nécessaire d'utiliser le script avec ces options :
 -e : Nom de fichier en entrée
 -s : Nom de fichier en sortie
 -t : Timestamp de début (00:00:00)
 -f : Timestamp de fin (00:00:00)
 -r : Résolution
 -c : Pour utiliser le chemin du fichier
"
}

############
# FONCTION #
############



##########
# SCRIPT #
##########

#RECUPERATION DES ARGUMENTS
while getopts ":e:s:t:f:cr:h" option
do
        case ${option} in
                e)
                fic=$OPTARG
                ;;
                s)
                nom_sortie=$OPTARG
                ;;
                t)
                time_start=$OPTARG
                ;;
                f)
                time_end=$OPTARG
                ;;
                c)
                ch_relatif=True
                ;;
                r)
                resolution=$OPTARG
                ;;
                h)
                usage
                exit 0
                ;;
                \?)
                echo "$OPTARG : option invalide"
                ;;
                :)
                echo "L'option $OPTARG requiert un argument"
                ;;
        esac
done

if [ ! ${ch_relatif} ];then
        cd "/mnt/c/Users/stani/Videos/Captures"
fi

if [ ! ${resolution} ];then
        resolution='480'
fi

#SI AUCUNE OPTION PASSEE EN ARGUMENT
if [ $OPTIND -eq 1 ];then
        usage
fi

#VERIFICATION FICHIER EN ENTREE
if [ ! -z "${fic}" ];then
        verif_fic_entree
fi

#VERIFICATION FICHIER EN SORTIE
if [ ! -z ${nom_sortie} ];then
        verif_nom_sortie
fi

while [ -z "${fic}" ];do
        printf "Nom de fichier : "
        read fic
        verif_fic_entree
done

        #FORMATTAGE DU NOM DE FICHIER
        nom_fic=`sed -E 's/(.*)\..*/\1/g' <<< ${fic}`
        ext_fic=`sed -E 's/.*\.(.*)/.\1/g' <<< ${fic}`

        echo "Nom : $nom_fic"
        echo "Ext : $ext_fic"

while [ -z ${time_start} ];do
        printf "Timestamp de début (00:00:00) : "
        read time_start
done

while [ -z ${time_end} ];do
        printf "Timestamp de fin (00:00:00) : "
        read time_end
done

while [ -z ${nom_sortie} ];do
        printf "Nom de sortie : "
        read nom_sortie
        verif_nom_sortie
done

ffmpeg -i "${nom_fic}${ext_fic}" -ss "$time_start" -to "$time_end" -async 1 "${nom_sortie}${ext_fic}"
if [ $? -ne 0 ];then
        echo "Problème au découpage de la video"
        exit 1
fi
ffmpeg -i "${nom_sortie}${ext_fic}" -vf "fps=30,scale=${resolution}:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 "${nom_sortie}.gif"
if [ $? -ne 0 ];then
        echo "Problème à la conversion en GIF"
        exit 1
fi

#Exécuté sur un Windows, émet un son
#powershell.exe '[console]::beep(5000,300)'

#############################
# SUPPRESSION FICHIERS TEMP #
#############################

if [ -e ${nom_sortie}${ext_fic} ];then
        rm -f ${nom_sortie}${ext_fic}
fi
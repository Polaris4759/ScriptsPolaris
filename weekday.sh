#!/bin/bash

#######################################
# Script créé le : 18/06/2022 à 00:47 #
#######################################

###############
# DESCRIPTION #
###############



#############
# VARIABLES #
#############


chscript=$(dirname $(readlink -f $0))
namescript=`basename "$(realpath $0)"`
blue="\e[36m"
red="\e[31m"
green="\e[32m"
orange="\e[33m"
def="\e[0m"

#################
# VERIFICATIONS #
#################



############
# FONCTION #
############

usage(){
    echo "
    Description : Ce script permet d'afficher les jours de la semaine pour une date donnée, année après année sur la période comprise entre année1 et année2.

    -a : Défini l'année de début
    -A : Défini l'année de fin
    -m : Défini le mois
    -j : Défini le jour
"
    exit 1
}

##########
# SCRIPT #
##########


while getopts ":a:A:m:j:" option
#Avec les deux points en début de ligne, l'erreur ne s'affichera pas dans le terminal
#Avec les deux points après une des options, cela indique que cette option requiert un argument
do
        case $option in
                a)
                annee1=$OPTARG
                ;;
                A)
                annee2=$OPTARG
                ;;
                m)
                mois=$OPTARG
                ;;
                j)
                jour=$OPTARG
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

if [ ${#annee1} -ne 4 ] || [ ${#annee2} -ne 4 ];then echo "Les années doivent contenir 4 chiffres";fi
if [ ${annee1} -ge ${annee2} ];then echo "L'année1 (-a) doit être plus petite que l'année2 (-A)";fi
if [ ${#mois} -eq 1 ];then mois=0${mois};fi
if [ ${#jour} -eq 1 ];then jour=0${jour};fi


if [ -z $annee1 ] || [ -z $annee2 ] || [ -z $mois ] || [ -z $jour ];then
    usage
fi

while [ $annee1 -le $annee2 ];do

    echo "$annee1 : $(date +%A -d${annee1}${mois}${jour})"

annee1=$(($annee1 + 1))
done


#############################
# SUPPRESSION FICHIERS TEMP #
#############################


#!/bin/bash

#########################################
# Fichier créé le : 08/03/2020 à 16:510 #
#########################################

#############
# FONCTIONS #
#############

palettesimple(){
    echo -e "\n\e[32mCouleurs de base"
    echo "Syntaxe : \e[<code>m"
    echo -e "Liste des codes :\e[0m"

    for i in {000..100}
    do
        if [ `expr $i % 10` -eq 0 ];then echo "";fi
        printf "\e[${i}m ${i} \e[0m"
    done
}

palette256fg(){
    echo -e "\n\e[32mPalette 256 couleurs pour la couleur de texte"
    echo "Syntaxe : \e[38;5;<code>m"
    echo -e "Liste des codes : \e[0m"

    for i in {000..256}
    do
        if [ `expr $i % 10` -eq 0 ];then echo "";fi
        printf "\e[38;5;${i}m ${i} \e[0m"
    done
}

palette256bg(){
    echo -e "\n\e[32mPalette 256 couleurs pour la couleur de fond"
    echo "Syntaxe : \e[48;5;<code>m"
    echo -e "Liste des codes : \e[0m"

    for i in {000..256}
    do
        if [ `expr $i % 10` -eq 0 ];then echo "";fi
        printf "\e[30;48;5;${i}m ${i} \e[0m "
    done
}

usage(){
    echo "
    Paramètres possible :
     -s : Palette simple
     -f : Palette 256 couleurs
     -b : Palette 256 couleurs avec couleurs de fond"
}

##########
# SCRIPT #
##########

if [ $# -eq 0 ];then
    palettesimple;palette256fg;palette256bg
fi

#RECUPERATION DES ARGUMENTS
while getopts ":sfbhu" option
do
    case ${option} in
        s)palettesimple;;
        f)palette256fg;;
        b)palette256bg;;
        h|u)usage;exit 0;;
        \?)echo "$OPTARG : option invalide";usage;;
        :)echo "L'option $OPTARG requiert un argument";usage;;
    esac
done

echo ""

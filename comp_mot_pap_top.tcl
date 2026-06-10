###########################################################################
# HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
# Institut REDS, Reconfigurable & Embedded Digital Systems
#
# Fichier      : comp_mot_pap_top.tcl
# Description  : Script de compilation des fichiers du
#                system de commande de 3 moteurs pas-a-pas
#
# Auteur       : Etienne Messerli
# Date         : 17.05.2024
# Version      : 0.0
#
# Utilise      : Labo CSN/SysLog2 chapitre MSS complexe
#
#--| Modifications |--------------------------------------------------------
# Ver  Aut.  Date        Description
#
#
############################################################################


# Complation des paquetages

# Complation des fichiers du mot_pap_top
vcom -2008 -reportprogress 300 -work work ../src/ilog_pkg.vhd
# ajouter ici vos fichier supplementaires :

vcom -2008 -reportprogress 300 -work work ../src/bit_filter.vhd
vcom -2008 -reportprogress 300 -work work ../src/UT.vhd
vcom -2008 -reportprogress 300 -work work ../src/UC.vhd
vcom -2008 -reportprogress 300 -work work ../src/cmd_mot_pap.vhd
vcom -2008 -reportprogress 300 -work work ../src/gen_top_sgn_mot.vhd
vcom -2008 -reportprogress 300 -work work ../src/phase_manager.vhd
vcom -2008 -reportprogress 300 -work work ../src/controller_mot_pap.vhd
vcom -2008 -reportprogress 300 -work work ../src/mot_pap_top.vhd

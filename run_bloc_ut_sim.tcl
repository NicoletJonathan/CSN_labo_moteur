###########################################################################
# HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
# Institut REDS, Reconfigurable & Embedded Digital Systems
#
# Fichier      : run_bloc_ut_sim.tcl.tcl
# Description  : Script permmettant le lancement de la simulation manuelle
#                de l'UC seul
# 
# Auteur       : Etienne Messerli
# Date         : 02.12.2014
# Version      : 1.0
#
# Utilise      : Labo CSN/SysLog2, commande de 3 moteurs pas-a-pas
#
#--| Modifications |--------------------------------------------------------
# Ver  Aut.  Date        Description
# 0.0  EMI  13.03.2013   Version originale
#                         
############################################################################


#create library work        
vlib work
#map library work to work
vmap work work

#compile all file 
do ../comp_mot_pap_top.tcl

# top_sim compilation
vcom -2008 -reportprogress 300 -work work   ../src_tb/console_sim_ut.vhd

#Chargement fichier pour la simulation
vsim -voptargs="+acc" work.console_sim 

#lance la console REDS
do /opt/tools_reds/REDS_console.tcl

#ajout signaux du composant simuler dans la fenetre wave
add wave UUT/*

#ouvre le fichier format predefini
#do ../wave_console_sim_uc.tcl

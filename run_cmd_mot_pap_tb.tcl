#!/usr/bin/tclsh

#------------------------------------------------------------------------------
#- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
#- Institut REDS, Reconfigurable & Embedded Digital Systems
#-
#- Fichier      : run_cmd_mot_pap_tb.tcl
#-
#- Description  : Script for running the mot pap top testbench
#-
#- Auteur       : L. Fournier
#- Date         : 28.05.2024
#- Version      : 1.0
#-
#- Used in      : Laboratoire de SysLog2/CSN
#-
#-| Modifications |------------------------------------------------------------
#- Version   Auteur      Date               Description
#- 1.0       LFR         28.05.2024         First version.
#------------------------------------------------------------------------------

# Main proc at the end #

#------------------------------------------------------------------------------
proc vhdl_compil { } {
    global Path_VHDL
    global Path_TB
    puts "\nVHDL compilation :"

    do ../comp_mot_pap_top.tcl

    vcom -2008 $Path_TB/html_report_pkg.vhd
    vcom -2008 $Path_TB/logger_html_pkg.vhd
    vcom -2008 $Path_TB/project_logger_pkg.vhd
    vcom -2008 $Path_TB/mot_pap_tb_pkg.vhd
    vcom -2008 $Path_TB/mot_pap_model.vhd
    vcom -2008 $Path_TB/test_mot_pap_pkg.vhd
    vcom -2008 $Path_TB/mot_pap_tb.vhd
}
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
proc sim_start {TESTCASE} {
    puts "\nStart simulation :"
    vsim -t 1ns -GTESTCASE=$TESTCASE work.mot_pap_tb
    #do ../wave.do
    add wave -r *
    wave refresh
    run -all
}
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
proc do_all {TESTCASE} {
    vhdl_compil
    sim_start $TESTCASE
}
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
proc help { } {
    puts "Call this script with one of the following options:"
    puts "    all         : compiles and run, with 1 arguments (see below)"
    puts "    comp_vhdl   : compiles all the VHDL files"
    puts "    sim         : starts a simulation, with 1 arguments (see below)"
    puts "    help        : prints this help"
    puts "    no argument : compiles and run with TESTCASE=0"
    puts ""
    puts "When 1 arguments are required, the order is:"
    puts "    1: TESTCASE, The test to run"
    puts "          0 -> run all the tests"
    puts "          1 -> run the initialisation tests"
    puts "          2 -> run the manual tests"
    puts "          3 -> run the automatique tests"
    puts "          4 -> run the error tests"
}
#------------------------------------------------------------------------------

## MAIN #######################################################################

# Compile folder
if {[file exists work] == 0} {
    mkdir work
    vlib work
    vmap work work
}

quietly set Path_VHDL     "../src"
quietly set Path_TB       "../src_tb"

global Path_VHDL
global Path_TB

# start of sequence

if {$argc>0} {
    if {[string compare $1 "all"] == 0} {
        do_all $2
    } elseif {[string compare $1 "comp_vhdl"] == 0} {
        vhdl_compil
    } elseif {[string compare $1 "sim"] == 0} {
        sim_start $2
    } elseif {[string compare $1 "help"] == 0} {
        help
    }
} else {
    do_all 0
}
###############################################################################
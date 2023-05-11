###############################################################################
##
## File          : memctrl.tcl
## Author        : Dominik Domanski
## Date          : 29/03/10
##
## Last Check-in :
## $Revision: 14 $
## $Author: dzunior $
## $Date: 2010-04-15 18:11:31 +0200 (Thu, 15 Apr 2010) $
##
###############################################################################
## Description:
## TCL script for MemCtrl block compilation
###############################################################################

    global TARGETS
    
    puts stdout "-- compile all files for memctrl"

    set LIB Acc
    vlib $LIB
    vmap $LIB $LIB
    set SRC $ROOT/memctrl/rtl
    vcom -93 -source -work $LIB	\
    $SRC/MemCtrl.vhd
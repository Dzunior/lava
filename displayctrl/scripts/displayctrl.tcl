###############################################################################
##
## File          : displayctrl.tcl
## Author        : Dominik Domanski
## Date          : 29/03/10
##
## Last Check-in :
## $Revision: 92 $
## $Author: dzunior $
## $Date: 2010-09-10 00:56:52 +0200 (vie, 10 sep 2010) $
##
###############################################################################
## Description:
## TCL script for DisplayCtrl block compilation
###############################################################################

    global TARGETS
    
    puts stdout "-- compile all files for displayctrl"

    set LIB Acc
    vlib $LIB
    vmap $LIB $LIB
    set SRC $ROOT/displayctrl/rtl
    vcom -93 -source -work $LIB \
    $SRC/fifo_cc.vhd \
    $SRC/DisplayCtrl.vhd
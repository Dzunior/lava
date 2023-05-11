###############################################################################
##
## File          : hostctrl.tcl
## Author        : Dominik Domanski
## Date          : 29/03/10
##
## Last Check-in :
## $Revision: 108 $
## $Author: dzunior $
## $Date: 2010-09-26 22:06:53 +0200 (dom, 26 sep 2010) $
##
###############################################################################
## Description:
## TCL script for HostCtrl block compilation
###############################################################################

    global TARGETS
    
    puts stdout "-- compile all files for hostctrl"

    set LIB Acc
    vlib $LIB
    vmap $LIB $LIB
    set SRC $ROOT/hostctrl/rtl
    vcom -93 -source -work $LIB \
    $SRC/host_fifo.vhd \
    $SRC/HostCtrl.vhd
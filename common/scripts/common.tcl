###############################################################################
##
## File          : common.tcl
## Author        : Dominik Domanski
## Date          : 29/03/10
##
## Last Check-in :
## $Revision: 21 $
## $Author: dzunior $
## $Date: 2010-07-15 01:40:41 +0200 (jue, 15 jul 2010) $
##
###############################################################################
## Description:
## TCL script for Common block compilation
###############################################################################

    global TARGETS
    
    puts stdout "-- compile all files for common"

    set LIB Acc
    vlib $LIB
    vmap $LIB $LIB
    set SRC $ROOT/common/rtl
    vcom -93 -source -work $LIB	\
    $SRC/AccTypes.vhd \
    $SRC/common.vhd \
    $SRC/ClkDiv.vhd \
    $SRC/Reset.vhd \
    $SRC/Csr.vhd
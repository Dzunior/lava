###############################################################################
##
## File          : top.tcl
## Author        : Dominik Domanski
## Date          : 29/03/10
##
## Last Check-in :
## $Revision: 107 $
## $Author: dzunior $
## $Date: 2010-09-25 01:42:35 +0200 (sáb, 25 sep 2010) $
##
###############################################################################
## Description:
## TCL script for top block compilation
###############################################################################

    global TARGETS
    
    puts stdout "-- compile all files for top"

    set LIB Acc
    vlib $LIB
    vmap $LIB $LIB
    set SRC $ROOT/top/rtl
    vcom -93 -source -work $LIB \
    $SRC/dcm_core.vhd \
    $SRC/spi_gen.vhd \
    $SRC/Accelerator.vhd
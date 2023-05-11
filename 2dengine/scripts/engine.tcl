###############################################################################
##
## File          : engine.tcl
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
## TCL script for 2D Engine block compilation
###############################################################################

    global TARGETS
    
    puts stdout "-- compile all files for engine"

    set LIB Acc
    vlib $LIB
    vmap $LIB $LIB
    set SRC $ROOT/2dengine/rtl
    vcom -93 -source -work $LIB	\
    $SRC/draw_fifo.vhd \
    $SRC/block_fifo.vhd \
    $SRC/font_rom.vhd \
    $SRC/Engine.vhd
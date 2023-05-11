#####################################################################
#
# acc_tb_compile.tcl
# Compiles all the testbench and board level modules
#
#####################################################################

set TB "$ROOT/tb/rtl"

set LIB Acc_tb
vlib $LIB
vmap $LIB $LIB
vcom -93 -source -work $LIB	\
    $TB/AccTbTypes.vhd  \
    $TB/Acc_tb_pkg.vhd  \
    $TB/Acc_tb.vhd 
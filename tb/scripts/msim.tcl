###############################################################################
##
## File          : msim.tcl
## Author        : Dominik Domanski
## Date          : 29/03/10
##
## Last Check-in :
## $Revision: 59 $
## $Author: dzunior $
## $Date: 2010-08-12 20:43:06 +0200 (jue, 12 ago 2010) $
##
###############################################################################
## Description:
## TCL script for general commands
###############################################################################
global ROOT
set ROOT "c:/addsvn_accelerator"

proc sw {} {write format wave wave.do}
proc lw {} {do wave.do}
proc ow {} {dataset open vsim.wlf; lw}
proc cw {} {dataset close -all}

proc dellibs {} {
    catch vmap maps
    set map [split $maps \n]
    foreach line $map {
        if {[regexp "maps to" $line ] & ![regexp "/" $line ]} {
            set lib [lindex $line 0]
            if {$lib!="altera" && $lib!="XILINXCORELIB" && $lib!="SIMPRIM" && $lib!="UNISIM"} {
                puts "Deleting library: $lib"
                catch "vmap -del $lib"
                catch "vdel -all -lib $lib"
            }
        }
    }
}
proc cm  {} {global ROOT; source "$ROOT/common/scripts/common.tcl"}
proc mc  {} {global ROOT; source "$ROOT/memctrl/scripts/memctrl.tcl"}
proc hc  {} {global ROOT; source "$ROOT/hostctrl/scripts/hostctrl.tcl"}
proc dc {} {global ROOT; source "$ROOT/displayctrl/scripts/displayctrl.tcl"}
proc en {} {global ROOT; source "$ROOT/2dengine/scripts/engine.tcl"}
proc fc {} {global ROOT; source "$ROOT/flashctrl/scripts/flashctrl.tcl"}
proc top {} {global ROOT; source "$ROOT/top/scripts/top.tcl"}
#proc tb  {} {global ROOT; source "$ROOT/tb/scripts/acc_tb_compile.tcl"}

proc pc  {} {
    global TARGETS
    cm;mc;hc;dc;en;fc;top
    }
    
proc tb {} {
    
    global TARGETS
    global ROOT
    set SRC $ROOT/tb/rtl
    puts stdout "-- compile all tb files for ACC"

    set LIB GS_RANDOM
    vlib $LIB
    vmap $LIB $LIB
    vcom -93 -source -work $LIB	\
    $SRC/GS_RANDOM.vhd
    
    set LIB Acc_tb
    vlib $LIB
    vmap $LIB $LIB
    vcom -93 -source -work $LIB \
    $SRC/AccTbTypes.vhd  \
    $SRC/Acc_tb_pkg.vhd \
    $SRC/mt48lc16m16a2.vhd \
    $SRC/m28w320cb.vhd \
    $SRC/Acc_tb.vhd
    }
    
proc test {TESTARG} {
    
    global TESTNAME DefaultRadix NumericStdNoWarnings StdArithNoWarnings SKIP_WAVES TB_MODE DBPATH PAGEPATH
    set TESTNAME $TESTARG
    global ROOT
    #transcript quietly

    set NumericStdNoWarnings 1
    set StdArithNoWarnings 1

    # Check that test directory exists
    if {[file exists $ROOT/tb/tests/$TESTNAME] == 0} {
        puts "ERROR: Test directory $TESTNAME does not exist."
        return
    }

    # Compile test file
    vcom -93 -source -work Acc_tb $ROOT/tb/tests/$TESTNAME/$TESTNAME.vhd
    vsim -t 1ps Acc_tb.Acc_tb

    # Put the test directory name into a string within the vhdl code
    set DIR "$ROOT/tb/tests/$TESTNAME/"
    set LEN "[string length $DIR]"
    force /Acc_tb_pkg/test_dir_len "10#$LEN"
    force /Acc_tb_pkg/test_directory(1 to $LEN) $DIR

    # Close previous log file
    transcript file ""

transcript file "$ROOT/tb/tests/$TESTNAME/$TESTNAME.log"
    puts "Test run: [clock format [clock seconds] -format "%d/%m/%y %H:%M"]"

    if {[info exists SKIP_WAVES]==0} then {
        # test Source the wave script file if it exists
        if {[file exists $ROOT/tb/tests/$TESTNAME/wave.do]} {
            do $ROOT/tb/tests/$TESTNAME/wave.do
        }
    }

    set start [clock seconds]
    run -a
    puts "Runtime: [expr [clock seconds]-$start] seconds"

    # Close log file
    transcript file ""
    if {[examine acc_tb_pkg/test_finished]==1} {
        set save_DefaultRadix $DefaultRadix
        set DefaultRadix hex
        # Return result (no. of errors)
        #set err_cnt [examine defhtbpackage/err_cnt]
        #set DefaultRadix $save_DefaultRadix
        #return [expr $err_cnt]
    } else {
        puts "Test not finished properly"
        return 1
    }
}
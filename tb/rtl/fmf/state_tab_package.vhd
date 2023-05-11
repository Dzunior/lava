--------------------------------------------------------------------------------
--  File name : state_tab_package.vhd
--------------------------------------------------------------------------------
--  Copyright (C) 1996 Free Model Foundry http://www.FreeModelFoundry.com/
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License version 2 as
--  published by the Free Software Foundation.
--
--  MODIFICATION HISTORY :
--
--  version | author | mod date | changes made
--      V2.0    rev3    23 MAR 96   Added copyright, synch reset tables
--------------------------------------------------------------------------------
LIBRARY IEEE;
USE     IEEE.Std_Logic_1164.ALL;
USE     IEEE.VITAL_primitives.all;
USE		IEEE.VITAL_timing.all;

PACKAGE state_tab_package IS

    --************************************************************

    ----------------------------------------------------------------------------
    -- 2 state table with active-high Reset
    ----------------------------------------------------------------------------
        CONSTANT st2R_tab : VitalStateTableType := ( 
 
        -----INPUTS-----|-PREV|-OUTPUTS--
        -- Viol CLK  R  | Sv0 |  Sv0'  -- 
        ----------------|-----|---------- 
 
        ( 'X', '-', '-', '-', 'X'), 
        ( '-', '-', 'X', '-', 'X'), 
        ( '-', '-', '1', '-', '0'), 
        ( '-', 'X', '0', '-', 'X'), 
        ( '-', '/', '0', '0', '1'), 
        ( '-', '/', '0', '1', '0'), 
        ( '-', '-', '-', '-', 'S') 

        ); -- end of VitalStateTableType definition

    ----------------------------------------------------------------------------
    -- 2 state table with active-high synchronous Reset
    ----------------------------------------------------------------------------
        CONSTANT st2Rs_tab : VitalStateTableType := ( 
 
        -----INPUTS-----|-PREV|-OUTPUTS--
        -- Viol CLK  R  | Sv0 |  Sv0'  -- 
        ----------------|-----|---------- 
 
        ( 'X', '-', '-', '-', 'X'), 
        ( '-', 'X', '-', '-', 'X'), 
        ( '-', '/', 'X', '-', 'X'), 
        ( '-', '/', '1', '-', '0'), 
        ( '-', '/', '0', '0', '1'), 
        ( '-', '/', '0', '1', '0'), 
        ( '-', '-', '-', '-', 'S') 

        ); -- end of VitalStateTableType definition

    ----------------------------------------------------------------------------
	-- 4 state table with active-high Reset
    ----------------------------------------------------------------------------
        CONSTANT st4R_tab : VitalStateTableType := (

        -----INPUTS-----|-PREV----|--OUTPUTS------
        -- Viol CLK  R  | Sv1 Sv0 |  Sv1' Sv0'  --
        ----------------|---------|---------------

        ( 'X', '-', '-', '-', '-', 'X', 'X'),
        ( '-', '-', 'X', '-', '-', 'X', 'X'),
        ( '-', '-', '1', '-', '-', '0', '0'),
        ( '-', 'X', '0', '-', '-', 'X', 'X'),
        ( '-', '/', '0', '0', '0', '0', '1'),
        ( '-', '/', '0', '0', '1', '1', '0'),
        ( '-', '/', '0', '1', '0', '1', '1'),
        ( '-', '/', '0', '1', '1', '0', '0'),
        ( '-', '-', '-', '-', '-', 'S', 'S') 

        ); -- end of VitalStateTableType definition

    ----------------------------------------------------------------------------
	-- 4 state table with active-high synchronous Reset
    ----------------------------------------------------------------------------
        CONSTANT st4Rs_tab : VitalStateTableType := (

        -----INPUTS-----|-PREV----|--OUTPUTS------
        -- Viol CLK  R  | Sv1 Sv0 |  Sv1' Sv0'  --
        ----------------|---------|---------------

        ( 'X', '-', '-', '-', '-', 'X', 'X'),
        ( '-', 'X', '-', '-', '-', 'X', 'X'),
        ( '-', '/', 'X', '-', '-', 'X', 'X'),
        ( '-', '/', '1', '-', '-', '0', '0'),
        ( '-', '/', '0', '0', '0', '0', '1'),
        ( '-', '/', '0', '0', '1', '1', '0'),
        ( '-', '/', '0', '1', '0', '1', '1'),
        ( '-', '/', '0', '1', '1', '0', '0'),
        ( '-', '-', '-', '-', '-', 'S', 'S') 

        ); -- end of VitalStateTableType definition

    ----------------------------------------------------------------------------
	-- 8 state table with active-high Reset
    ----------------------------------------------------------------------------
        CONSTANT st8R_tab : VitalStateTableType := (

        -----INPUTS-----|-PREV--------|--OUTPUTS----------
        -- Viol CLK  R  | Sv2 Sv1 Sv0 | Sv2' Sv1' Sv0'  --
        ----------------|-------------|-------------------

        ( 'X', '-', '-', '-', '-', '-', 'X', 'X', 'X'),
        ( '-', '-', 'X', '-', '-', '-', 'X', 'X', 'X'),
        ( '-', '-', '1', '-', '-', '-', '0', '0', '0'),
        ( '-', 'X', '0', '-', '-', '-', 'X', 'X', 'X'),
        ( '-', '/', '0', '0', '0', '0', '0', '0', '1'),
        ( '-', '/', '0', '0', '0', '1', '0', '1', '0'),
        ( '-', '/', '0', '0', '1', '0', '0', '1', '1'),
        ( '-', '/', '0', '0', '1', '1', '1', '0', '0'),
        ( '-', '/', '0', '1', '0', '0', '1', '0', '1'),
        ( '-', '/', '0', '1', '0', '1', '1', '1', '0'),
        ( '-', '/', '0', '1', '1', '0', '1', '1', '1'),
        ( '-', '/', '0', '1', '1', '1', '0', '0', '0'),
        ( '-', '-', '-', '-', '-', '-', 'S', 'S', 'S')

        ); -- end of VitalStateTableType definition
 
    ----------------------------------------------------------------------------
	-- 8 state table with active-high synchronous Reset
    ----------------------------------------------------------------------------
        CONSTANT st8Rs_tab : VitalStateTableType := (

        -----INPUTS-----|-PREV--------|--OUTPUTS----------
        -- Viol CLK  R  | Sv2 Sv1 Sv0 | Sv2' Sv1' Sv0'  --
        ----------------|-------------|-------------------

        ( 'X', '-', '-', '-', '-', '-', 'X', 'X', 'X'),
        ( '-', 'X', '-', '-', '-', '-', 'X', 'X', 'X'),
        ( '-', '/', 'X', '-', '-', '-', 'X', 'X', 'X'),
        ( '-', '/', '1', '-', '-', '-', '0', '0', '0'),
        ( '-', '/', '0', '0', '0', '0', '0', '0', '1'),
        ( '-', '/', '0', '0', '0', '1', '0', '1', '0'),
        ( '-', '/', '0', '0', '1', '0', '0', '1', '1'),
        ( '-', '/', '0', '0', '1', '1', '1', '0', '0'),
        ( '-', '/', '0', '1', '0', '0', '1', '0', '1'),
        ( '-', '/', '0', '1', '0', '1', '1', '1', '0'),
        ( '-', '/', '0', '1', '1', '0', '1', '1', '1'),
        ( '-', '/', '0', '1', '1', '1', '0', '0', '0'),
        ( '-', '-', '-', '-', '-', '-', 'S', 'S', 'S')

        ); -- end of VitalStateTableType definition
 
    ----------------------------------------------------------------------------

END state_tab_package;
-------------------------------------------------------------------------------
--
-- File         : AccTbTypes.vhd
-- Author       : Dominik Domanski
-- Date         : 14/04/10
--
-- Last Check-in :
-- $Revision: 119 $
-- $Author: dzunior $
-- $Date: 2010-10-11 01:33:00 +0200 (lun, 11 oct 2010) $
--
-------------------------------------------------------------------------------
-- Description:
-- Types for the Main Test Bench
-------------------------------------------------------------------------------
library std;
use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;

library Acc;
use Acc.AccTypes.all;

package AccTbTypes is

constant CSR_WRITE  : std_logic:='0';
constant CSR_READ   : std_logic:='1';
constant CSR        : std_logic:='1';
constant MEM        : std_logic:='0';
   
type RegTransaction is record
    initRd  : std_logic;
    initWr  : std_logic;
    accept  : std_logic;
    data    : std_logic_vector(15 downto 0);
end record;

signal error_counter : natural:=0;
    
end package AccTbTypes;

package body AccTbTypes is



end package body AccTbTypes;



-------------------------------------------------------------------------------
--
-- File         : Reset.vhd
-- Author       : Dominik Domanski
-- Date         : 29/03/10
--
-- Last Check-in :
-- $Revision: 106 $
-- $Author: dzunior $
-- $Date: 2010-09-25 01:23:57 +0200 (sáb, 25 sep 2010) $
--
-------------------------------------------------------------------------------
-- Description:
-- Reset synchronization (for different clock domains).
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity Reset is
    port (arst : in  std_logic;
          clk  : in  std_logic;
          rst  : out std_logic:='1');
end entity Reset;

architecture RTL of Reset is

signal q1,q2,q3 : std_logic:='1';	
begin
	name:process (clk) is
        begin
            if rising_edge(clk) then
	            q1 <= arst;
	            q2 <= q1;
	            q3 <= q2;
	            rst <= q3;
            end if;
        end process name;
    
end architecture RTL;
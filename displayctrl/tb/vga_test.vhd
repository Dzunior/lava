-------------------------------------------------------------------------------
--
-- File         : vga_test.vhd
-- Author       : Dominik Domanski
-- Date         : 07/07/10
--
-- Last Check-in :
-- $Revision: 107 $
-- $Author: dzunior $
-- $Date: 2010-09-25 01:42:35 +0200 (sáb, 25 sep 2010) $
--
-------------------------------------------------------------------------------
-- Description:
-- simple test for vga.vhd
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library std;
use std.textio.all;

entity vga_test is
end vga_test;

library work;
use work.XgaTypes.all;

architecture tb of vga_test is

constant SYS_CLK_PERIOD	: time:=10000 ps;
constant PIXEL_CLK_PERIOD	: time:=9259 ps;
signal data 				: unsigned(31 downto 0):=x"0000_0000";
signal data_slv 			: std_logic_vector(31 downto 0):=x"0000_0000";
signal clk,rst,start,wr,pixel_clk : std_logic:='0';
signal display_config   : DisplayConfigRecord;
-------------------------------------------------------------
-- Component declaration of the User Test
-------------------------------------------------------------
    --component test
    --end component;

    
begin
------------------------------------------------------------
-- Component Instatiation of the User Test
------------------------------------------------------------
    --MAIN_TEST: test;
    
   clk<=NOT clk after (SYS_CLK_PERIOD/2);
   pixel_clk<=NOT pixel_clk after (PIXEL_CLK_PERIOD/2);	
	
    main : process
        variable outline : LINE;
    begin
        rst<='1';
        wait for 300 ns;
        rst<='0';
        WRITE(outline,string'("Reset done ..."));WRITELINE(output,outline);
        start<='1';
        wait until falling_edge(start);
    end process main;   
    
    process(clk)
    begin
        if rising_edge(clk) then
            wr<='1';
            data_slv <= std_logic_vector(data);
            data <= data+1;
        end if;    
    end process;
    
    U_TEST:entity work.DisplayCtrl
    port map (
      rst           => rst,            
      clk           => clk, 
		pixel_clk	  => pixel_clk,	
      wr            => wr,  
      pixel_data_in => data_slv, 		
      eof           => open,  
      r             => open,
      g             => open,
      b             => open, 
      hsync_n       => open,  
      vsync_n       => open,  
      blank         => open,
	   display_config=> display_config		
      );

end architecture tb;  
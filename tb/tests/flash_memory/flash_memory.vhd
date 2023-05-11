-------------------------------------------------------------------------------
--
-- File         : flash_memory.vhd
-- Author       : Dominik Domanski
-- Date         : 20/08/10
--
-- Last Check-in :
-- $Revision: 134 $
-- $Author: dzunior $
-- $Date: 2010-10-26 17:51:22 +0200 (mar, 26 oct 2010) $
--
-------------------------------------------------------------------------------
-- Description:
-- FLASH_MEMORY test - single write and read memory ops
-------------------------------------------------------------------------------
library std;
use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;

library Acc_tb;
use Acc_tb.Acc_tb_pkg.all;
use Acc_tb.AccTbTypes.all;
library GS_RANDOM;
use GS_random.rng2.all;
library Acc;
use Acc.AccTypes.all;
use Acc.common.all;

entity test is
end test;

architecture tb of test is
-- Main signals, types
--signal data : std_logic_vector(15 downto 0);

begin
-- Main Test Process
    process
    
    variable outline : LINE;
    variable random_uniform : uniform;
    variable expected_data : integer;
    variable data : unsigned(15 downto 0);
    variable address : unsigned(HADDR_WIDTH-1 downto 0);
    variable pixel_x1,pixel_x2: unsigned(X_RES_SIZE-1 downto 0);
    variable pixel_y1,pixel_y2: unsigned(Y_RES_SIZE-1 downto 0);
        begin
        -- The start signal is asserted once all initialisation has taken place
        wait until (start='1');
        LOG("TEST START: FLASH_MEMORY");
        -- time needed to finish CLEAR_MEM
        wait for 14 ms;
        address:=(others=>'0');
        write_memory(regH,FLASH,MEM,'0',address,x"0098");
        read_memory(regH,FLASH,MEM,'0',x"000081",data);
        write_memory(regH,FLASH,MEM,'0',address,x"0098");
        read_memory(regH,FLASH,MEM,'0',x"000082",data);
        -- 1. Check IC data
        assert false report "1.Read Electronic Signature" severity note;
        address:=(others=>'0');
        write_memory(regH,FLASH,MEM,'0',address,x"0090");
        read_memory(regH,FLASH,MEM,'0',address,data);
        assert false report "Manufacturer code:"&integer'image(to_integer(data))
        severity note;
        address(0):='1';
        write_memory(regH,FLASH,MEM,'0',address,x"0090");
        read_memory(regH,FLASH,MEM,'0',address,data);
        assert false report "Device code:"&integer'image(to_integer(data))
        severity note;
        -- 2. Unlock block  
        address:=x"001000";
        assert false report "2.Unlock the block" severity note;
        write_memory(regH,FLASH,MEM,'0',address,x"0060");
        write_memory(regH,FLASH,MEM,'0',address,x"00D0");
        -- 2. Write to FLASH 
        address:=x"001000";
        assert false report "2.Write to FLASH" severity note;
        for a in 0 to 255 loop
            write_memory(regH,FLASH,MEM,'0',address,x"0010");
            write_memory(regH,FLASH,MEM,'0',address,to_unsigned(a,16));
            address:=address+1;
            wait for 125 us;
        end loop;
		address:=x"001000";
		for a in 0 to 4 loop
			mem_copy(regH,FLASH,SDRAM,x"008000",x"000000",64);
			address:=address+64;
		end loop;	
        -- 2. Read to FLASH 
        address:=x"001000";
        assert false report "3.Read from FLASH" severity note;
        for a in 0 to 255 loop
            write_memory(regH,FLASH,MEM,'0',address,x"00FF");
            read_memory(regH,FLASH,MEM,'0',address,data);
            assert a=to_integer(unsigned(data)) report "Wrong data! expected:"&integer'image(a)
            &" actual:"&integer'image(to_integer(data)) severity error;
            address:=address+1;
            wait for 125 us;
        end loop;
        wait for 10 us;
        -- End of Test
        finish;
    end process;
end tb;
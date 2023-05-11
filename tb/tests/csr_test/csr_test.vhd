-------------------------------------------------------------------------------
--
-- File         : csr_test.vhd
-- Author       : Dominik Domanski
-- Date         : 29/09/10
--
-- Last Check-in :
-- $Revision: 107 $
-- $Author: dzunior $
-- $Date: 2010-09-25 01:42:35 +0200 (sáb, 25 sep 2010) $
--
-------------------------------------------------------------------------------
-- Description:
--  CSR test - tests CSR R/W
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

begin
    -- Main Test Process
    process
    
    variable outline : LINE;
    variable random_uniform : uniform;
    variable expected_data : integer;
    variable data : unsigned(15 downto 0);
    variable color : unsigned(15 downto 0):=x"1234";
    variable font_x : unsigned(15 downto 0):=x"0246";
    variable font_y : unsigned(15 downto 0):=x"0135";
    variable transparency_color : unsigned(15 downto 0):=x"5678";
    variable buffer_id : unsigned(15 downto 0):=x"0000";
    variable config : unsigned(15 downto 0):=x"0001";
    
        begin
        -- The start signal is asserted once all initialisation has taken place
        wait until (start='1');
        LOG("TEST START: CSR_TEST");
        -- time needed to finish CLEAR_MEM
        wait for 15 ms;
        LOG("1.Write data to CSRs");
        write_memory(regH,SDRAM,CSR,CSR_WRITE,x"00000"&CSR_COLOR,color);
        write_memory(regH,SDRAM,CSR,CSR_WRITE,x"00000"&CSR_FONT_X,font_x);
        write_memory(regH,SDRAM,CSR,CSR_WRITE,x"00000"&CSR_FONT_Y,font_y);
        write_memory(regH,SDRAM,CSR,CSR_WRITE,x"00000"&TRANSPARENCY,transparency_color);
        write_memory(regH,SDRAM,CSR,CSR_WRITE,x"00000"&BUFFER_REG,buffer_id);
        write_memory(regH,SDRAM,CSR,CSR_WRITE,x"00000"&CONFIG_REG,config);
        LOG("2.Read data from CSRs");
        read_memory(regH,SDRAM,CSR,CSR_READ,x"00000"&CSR_COLOR,data);
        assert data=color report "Wrong CSR_COLOR" severity error;
        read_memory(regH,SDRAM,CSR,CSR_READ,x"00000"&CSR_FONT_X,data);
        assert data=font_x report "Wrong CSR_FONT_X" severity error;
        read_memory(regH,SDRAM,CSR,CSR_READ,x"00000"&CSR_FONT_Y,data);
        assert data=font_y report "Wrong CSR_FONT_Y" severity error;
        read_memory(regH,SDRAM,CSR,CSR_READ,x"00000"&TRANSPARENCY,data);
        assert data=transparency_color report "Wrong TRANSPARENCY" severity error;
        read_memory(regH,SDRAM,CSR,CSR_READ,x"00000"&BUFFER_REG,data);
        assert data=buffer_id report "Wrong BUFFER_REG" severity note;
        -- read_memory(regH,SDRAM,CSR,CSR_READ,x"00000"&CONFIG_REG,data);
        --assert data=config report "Wrong CONFIG_REGISTER" severity error;
        read_memory(regH,SDRAM,CSR,CSR_READ,x"00000"&BUILD_VERSION,data);
        assert data=unsigned(BUILD_NUMBER) report "Wrong BUILD_VERSION" severity error;
        wait for 10 us;
        -- End of Test
        finish;
    end process;
end tb;
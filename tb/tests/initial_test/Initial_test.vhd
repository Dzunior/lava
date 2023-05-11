-------------------------------------------------------------------------------
--
-- File         : Initial_test.vhd
-- Author       : Dominik Domanski
-- Date         : 27/03/10
--
-- Last Check-in :
-- $Revision: 107 $
-- $Author: dzunior $
-- $Date: 2010-09-25 01:42:35 +0200 (sáb, 25 sep 2010) $
--
-------------------------------------------------------------------------------
-- Description:
--  Test example
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
    variable pixel_x1,pixel_x2: std_logic_vector(X_RES_SIZE-1 downto 0);
    variable pixel_y1,pixel_y2: std_logic_vector(Y_RES_SIZE-1 downto 0);
        begin
        -- The start signal is asserted once all initialisation has taken place
        wait until (start='1');
        LOG("TEST START: Initial_Test");
        -- time needed to finish CLEAR_MEM
        wait for 13800 us;
        for a in 0 to 0 loop
            for i in 0 to 20 loop
                --Initialise random number generator, specifying minimum and maximum values
                random_uniform:=InitUniform(i, 2.0, 512.0);
                GenRnd(random_uniform);
                pixel_x1:=std_logic_vector(to_unsigned(i+10,X_RES_SIZE));
                pixel_y1:=std_logic_vector(to_unsigned(i+10,Y_RES_SIZE));
                pixel_x2:=std_logic_vector(to_unsigned(i+14,X_RES_SIZE));
                pixel_y2:=std_logic_vector(to_unsigned(i+16,Y_RES_SIZE));
                csr(regH,slv(CSR_COLOR),x"DAAC");
                csr(regH,slv(CSR_FONT_X),x"0005");
                csr(regH,slv(CSR_FONT_Y),x"000A");
                draw_line(regH,pixel_x1,pixel_y1,pixel_x2,pixel_y2);
                --buffer_mem_copy(regH,x"001000",pixel_x1,pixel_y1,pixel_x2,pixel_y2);
                mem_buffer_copy(regH,SDRAM,x"001000",pixel_x1,pixel_y1,pixel_x2,pixel_y2);
                --draw_buffer(regH);
                --draw_point(regH,12,43);
                -- pixel_x1:=std_logic_vector(to_unsigned(i+10,X_RES_SIZE));
                -- pixel_y1:=std_logic_vector(to_unsigned(i+10,Y_RES_SIZE));
                -- pixel_x2:=std_logic_vector(to_unsigned(i+14,X_RES_SIZE));
                -- pixel_y2:=std_logic_vector(to_unsigned(i+16,Y_RES_SIZE));
                --draw_text(regH,7,"DOMINIK ");
                --copy_block(regH,x"100000",b"00_0001_0000",b"00_0001_0100",b"00_0001_1000",b"00_0001_0110");
                -- data_write(regH,COPY_BLOCK&x"010");
                -- data_write(regH,x"0"&b"00"&pixel_y1);
                -- data_write(regH,x"0000");
                -- data_write(regH,x"0000");
                -- data_write(regH,x"000E");
                -- data_write(regH,x"0010");
                -- data_write(regH,DRAW_BUFFER&x"000");
                wait for SCLK_PERIOD;
            end loop;
        end loop;    
        wait for 2 ms;
        -- End of Test
        finish;
    end process;
end tb;
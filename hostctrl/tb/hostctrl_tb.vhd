-------------------------------------------------------------------------------
--
-- File         : hostctrl_tb.vhd
-- Author       : Dominik Domanski
-- Date         : 08/07/10
--
-- Last Check-in :
-- $Revision: 107 $
-- $Author: dzunior $
-- $Date: 2010-09-25 01:42:35 +0200 (sáb, 25 sep 2010) $
--
-------------------------------------------------------------------------------
-- Description:
-- simple test for HostCtrl.vhd
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library std;
use std.textio.all;

library GS_random;
use GS_random.rng2.all;

entity hostctrl_tb is
end hostctrl_tb;

architecture tb of hostctrl_tb is

constant SYS_CLK_PERIOD:time:=25 ns;
constant SPI_CLK_PERIOD:time:=66 ns;

signal clk,rst,start,sclk,en,sclk_en,ss_n : std_logic:='0';
signal mosi,miso,hostctrl_empty,hostctrl_rdreq : std_logic;
signal local_data : std_logic_vector(15 downto 0);
type data_array is array(0 to 20) of std_logic_vector(15 downto 0);
signal data_word : data_array; 
-------------------------------------------------------------
-- Component declaration of the User Test
-------------------------------------------------------------
    component test
    end component;

begin
------------------------------------------------------------
-- Component Instatiation of the User Test
------------------------------------------------------------
    MAIN_TEST: test;
    
    clk<=NOT clk after (SYS_CLK_PERIOD/2);
    sclk<=NOT sclk after (SPI_CLK_PERIOD/2);
    sclk_en <= sclk and en;
    
    main : process
        variable outline : LINE;
    begin
        rst<='1';
        wait for 300 ns;
        rst<='0';
        WRITE(outline,string'("Reset done ..."));WRITELINE(output,outline);
        wait until start='0';
        assert false report "End of the test" severity ERROR;
    end process main;   
    
    process
        variable random_uniform : uniform;
    begin
        start<='1';
        ss_n <='1';
        hostctrl_rdreq <= '0';
        wait for SPI_CLK_PERIOD*20;
        --Initialise random number generator, specifying minimum and maximum values
        random_uniform:=InitUniform(1, 2.0, 65536.0);
        for i in 0 to 20 loop
            GenRnd(random_uniform);
            data_word(i)<=std_logic_vector(to_unsigned(integer(random_uniform.rnd),16));
            wait until falling_edge(sclk);
            ss_n<='0';
            wait until falling_edge(sclk);
            wait until falling_edge(sclk);
            wait until falling_edge(sclk);
            en <='1';
            for a in 15 downto 0 loop
                mosi <= data_word(i)(a);
                wait until falling_edge(sclk);
            end loop;
            en <='0';
            wait until falling_edge(sclk);
            ss_n<='1';
            wait until hostctrl_empty='0';
            wait until falling_edge(sclk);
            assert local_data=data_word(i) report "Wrong data!!" severity ERROR;
            assert false report "local_data="&integer'image(to_integer(unsigned(local_data)))&"   data_word("&integer'image(i)&")="
            &integer'image(to_integer(unsigned(data_word(i)))) severity NOTE;
            wait until falling_edge(clk);
            hostctrl_rdreq<='1';
            wait until falling_edge(clk);
            hostctrl_rdreq<='0';
        end loop;
        start<='0';
        wait until falling_edge(sclk);
    end process;
    
    U_TEST:entity work.hostctrl
    port map(
        -- host side
        rst             => rst, 
        sclk            => sclk_en,
        mosi            => mosi,
        miso            => miso,
        ss_n            => ss_n,
        -- accelerator side
        local_clk       => clk,
        local_data      => local_data,
        hostctrl_rdreq  => hostctrl_rdreq,
        hostctrl_empty  => hostctrl_empty
        );

end architecture tb;
-------------------------------------------------------------------------------
--
-- File         : data_gen.vhd
-- Author       : Dominik Domanski
-- Date         : 20/09/10
--
-- Last Check-in :
-- $Revision: 13 $
-- $Author: dzunior $
-- $Date: 2010-04-06 18:07:12 +0200 (Tue, 06 Apr 2010) $
--
-------------------------------------------------------------------------------
-- Description:
--  Data generator
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.AccTypes.all;
use work.common.all;

entity data_gen is
    port (
        rst             : in std_logic; -- reset
        clk             : in  std_logic;-- system clock
        -- ftdi interface
        rxf_n           : out std_logic;
        rd_n            : in std_logic;
        data            : out std_logic_vector(7 downto 0);
        txe_n           : out std_logic;
        wr              : in std_logic
        );
end entity data_gen;

architecture rtl of data_gen is

type StateType is (IDLE,READ_OP,WRITE_OP,WAIT_STATE);
signal state   : StateType;
signal data_en  : std_logic;
signal usb_data : std_logic_vector(7 downto 0);
signal hostctrl_wreq : std_logic;
signal clk_div  : unsigned(1 downto 0);
signal clk_en   : std_logic;
signal usb_data_out : std_logic_vector(7 downto 0);
signal hostctrl_full_int : std_logic;

begin
 
data <= usb_data_out when data_en='1' else (others=>'Z');
hostctrl_full <= hostctrl_full_int;


U_spi_gen:process(clk,rst)
    begin
        if rst='1' then
            state <= IDLE;
            rst_n <= '0';
            rd_n <= '1';
            usb_data_out <= (others=>'0');
            usb_data <= (others=>'0');
            data_en <= '0';
            hostctrl_wreq <= '0';
            wr <= '0';
        elsif rising_edge(clk) then
            if clk_en='1' then
                rst_n <= '1';
                rd_n <='1';
                hostctrl_wreq <= '0';
                case state is
                    when IDLE =>
                        if hostctrl_full_int='0' then
                            if rxf_n='0' then
                                rd_n <='0';
                                state <= READ_OP;
                            end if;	
                        end if;	
                    when READ_OP =>
                        hostctrl_wreq <= '1';
                        usb_data <= data;
                        state <= WAIT_STATE;
                    when WAIT_STATE =>
                        if rxf_n='1' then
                            state <= IDLE;
                        else
                            state <= WAIT_STATE;
                        end if;	
                    when WRITE_OP =>
                        null;
                    when others =>
                        null;
                end case;  
            end if;	
        end if;    
    end process;
    
end architecture rtl;
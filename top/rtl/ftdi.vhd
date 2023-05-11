-------------------------------------------------------------------------------
--
-- File         : ftdi.vhd
-- Author       : Dominik Domanski
-- Date         : 19/09/10
--
-- Last Check-in :
-- $Revision: 13 $
-- $Author: dzunior $
-- $Date: 2010-04-06 18:07:12 +0200 (Tue, 06 Apr 2010) $
--
-------------------------------------------------------------------------------
-- Description:
--  USB communciation
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.AccTypes.all;
use work.common.all;

entity ftdi is
    port (
		rst			    : in std_logic; -- reset
        clk             : in  std_logic;  -- system clock
		-- ftdi interface
		rst_n           : out std_logic;  -- ftdi reset 
		rxf_n			: in std_logic;
		rd_n			: out std_logic;
		data			: inout std_logic_vector(7 downto 0);
		txe_n			: in std_logic;
		wr				: out std_logic;
		-- 2D Engine interface
		hostctrl_data   : out std_logic_vector (HOST_BUS_WIDTH-1 downto 0);
        hostctrl_rdreq  : in std_logic;
        hostctrl_empty  : out std_logic;
        read_data       : in std_logic_vector (HOST_BUS_WIDTH-1 downto 0);
        read_ack        : in std_logic;
        read_done       : out std_logic
        );
end entity ftdi;

architecture rtl of ftdi is

type StateType is (IDLE,READ_OP,WRITE_OP,WAIT_STATE);
signal state   : StateType;
signal data_en : std_logic;
signal data_in : std_logic_vector(7 downto 0);
signal 

begin

data <= data_in when data_en='1' else 'Z';

U_CE:process(clk,rst)
	begin
		if rst='1' then
			clk_en='0';
			clk_div <= (others=>'0');
		elsif rising_edge(clk)
			if clk_div=b"111" then
				clk_en <= '1';
				clk_div <= (others=>'0');
			else
				clk_en <= '0';
				clk_div <= clk_div+1;
			end if;	
		end if;
	end process;

U_spi_gen:process(clk,rst)
    begin
        if rst='1' then
            state <= IDLE;
			rst_n <= '0';
			rd_n <= '1';
			txe_n<= '1';
			data_in <= (others=>'0');
        elsif rising_edge(clk) then
			if clk_en='1' then
				rst_n <= '1';
				rd_n <='1';
				case state is
					when IDLE =>
						if hostctrl_full='0' then
							if rxf_n='0' then
								rd_n <='0';
								state <= READ_OP;
							end if;	
						end if;	
					when READ_OP =>
						hostctrl_wreq <= '1';
						hostctrl_data_in <= data;
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
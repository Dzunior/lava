-------------------------------------------------------------------------------
--
-- File         : rw_memory.vhd
-- Author       : Dominik Domanski
-- Date         : 12/08/10
--
-- Last Check-in :
-- $Revision: 13 $
-- $Author: dzunior $
-- $Date: 2010-04-06 18:07:12 +0200 (Tue, 06 Apr 2010) $
--
-------------------------------------------------------------------------------
-- Description:
--  RW_MEMORY test - single write and read memory ops
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


architecture rtl of test is

signal clk : std_logic; 
signal stan : integer range 0 to 9;
signal data_out : std_logic_vector(15 downto 0);
signal reset    : std_logic;
signal flash_rdreq      : std_logic;
signal flash_wreq       : std_logic;
signal flash_rwaddr     : std_logic_vector (FLASH_ADDR_WIDTH-1 downto 0);
signal flash_rdata      : std_logic_vector (FLASH_BUS_WIDTH-1 downto 0);
signal flash_wdata      : std_logic_vector (FLASH_BUS_WIDTH-1 downto 0);
signal flash_ready      : std_logic;
signal flash_op_valid   : std_logic; 
    
component FlashCtrl is
    port (
        clk     	    : in  std_logic;						
        rst		        : in  std_logic;						
        flash_rdreq     : in std_logic;											
        flash_wreq      : in std_logic;						
        flash_rwaddr    : in std_logic_vector (FLASH_ADDR_WIDTH-1 downto 0);	
        flash_rdata     : out std_logic_vector (FLASH_BUS_WIDTH-1 downto 0);
        flash_wdata     : in std_logic_vector (FLASH_BUS_WIDTH-1 downto 0);        
        flash_ready     : out std_logic;													
        flash_op_valid  : out std_logic;					
        flash_ce_n	    : out std_logic;						
        flash_oe_n	    : out std_logic;						
        flash_we_n	    : out std_logic;
        flash_rp_n      : out std_logic;
        addr		    : out std_logic_vector (21 downto 0);	
        data		    : inout std_logic_vector (15 downto 0)	
    );
end component;

 
    
begin

    U_FlashCtrl: entity work.FlashCtrl
    port map(
        clk             => clk,
        rst             => reset,
        --User side
        flash_rdreq     => flash_rdreq,
        flash_wreq      => flash_wreq,
        flash_rwaddr    => flash_rwaddr,
        flash_rdata	    => flash_rdata,
        flash_wdata	    => flash_wdata,
        flash_ready		=> flash_ready,
        flash_op_valid	=> flash_op_valid,
        --Flash memory side
        flash_ce_n	    => flash_ce_n,
        flash_oe_n	    => flash_oe_n,
        flash_we_n	    => flash_we_n,
        addr		    => flash_addr,
        data		    => flash_data,
        flash_rp_n      => flash_rp_n
    );

    FLASH_model : entity work.m28w320cb
    port map(
        A20     => flash_addr(20),        
        A19     => flash_addr(19),       
        A18     => flash_addr(18),       
        A17     => flash_addr(17),       
        A16     => flash_addr(16),            
        A15     => flash_addr(15),            
        A14     => flash_addr(14),       
        A13     => flash_addr(13),            
        A12     => flash_addr(12),            
        A11     => flash_addr(11),       
        A10     => flash_addr(10),            
        A9      => flash_addr(9),           
        A8      => flash_addr(8),       
        A7      => flash_addr(7),           
        A6      => flash_addr(6),            
        A5      => flash_addr(5),       
        A4      => flash_addr(4),            
        A3      => flash_addr(3),            
        A2      => flash_addr(2),       
        A1      => flash_addr(1),            
        A0      => flash_addr(0),            
        D15     => flash_data(15),       
        D14     => flash_data(14),       
        D13     => flash_data(13),       
        D12     => flash_data(12),       
        D11     => flash_data(11),       
        D10     => flash_data(10),       
        D9      => flash_data(9),        
        D8      => flash_data(8),        
        D7      => flash_data(7),        
        D6      => flash_data(6),        
        D5      => flash_data(5),        
        D4      => flash_data(4),        
        D3      => flash_data(3),        
        D2      => flash_data(2),        
        D1      => flash_data(1),        
        D0      => flash_data(0),        
        CENeg   => flash_ce_n,
        OENeg   => flash_oe_n,       
        WENeg   => flash_we_n,       
        RPNeg   => flash_rp_n,      
        WPNeg   => '1',       
        VPP     => '1'
    );      

LED7_AN_O <= (others => '0');

clk <= not clk after  6.666 ns;

process
    begin
        reset <='0';
        wait for 100 ns;
        reset <= '1';
        wait until reset='0';
    end process;

process(clk,reset)
begin
	if(reset='0')then
		stan <= 0;				
		data_out   <= (others => '0');
		LED7_SEG_O <= (others => '1');
		writeAddr  <= (others => '1');
		readAddr   <= (others => '1');
        doRead <= '0';   
        doWrite <= '0';          
	elsif(clk_50MHz'event and clk_50MHz='1')then
		
		-- write
		if(stan=0)then
			writeAddr <= writeAddr + '1';
			writeData <= X"0090";
			stan<=1;
		end if;
		
		if(stan=1 and canWrite='1')then
			doWrite <= '1';
			stan<=2;
		end if;
		
		if(stan=2)then
			stan<=3;
		end if;
		
		if(stan=3)then
			stan<=4;
		end if;
		
		if(stan=4)then
			stan<=5;
            doWrite <= '0';
		end if;
		
		-- read
		if(stan=5)then
			readAddr <= readAddr + '1';
			stan<=6;
		end if;
		
		if(stan=6 and canRead='1')then
			doRead <= '1';
			stan <= 7;
		end if;
		
		if(stan=7)then
			stan <= 8;
		end if;
		
		if(stan=8 and canRead='1')then
			data_out <= readData;
		end if;
		
		
		if(data_out=X"0090")then
			licznik := licznik + 1;
			stan <= 0;
		end if;
		
		-- wyswietlenie odpowiedzi
		if(licznik=4194304)then
			LED7_SEG_O <= (others => '0');
			licznik := 0;
			stan <= 8;
		end if;

	end if;
end process;

end rtl;
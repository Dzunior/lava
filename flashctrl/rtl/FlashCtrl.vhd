-------------------------------------------------------------------------------
--
-- File         : FlashCtrl.vhd
-- Author       : Dominik Domanski
-- Date         : 14/08/10
--
-- Last Check-in :
-- $Revision: 129 $
-- $Author: dzunior $
-- $Date: 2010-10-26 17:40:48 +0200 (mar, 26 oct 2010) $
--
-------------------------------------------------------------------------------
-- Description:
-- This block is responisble for communication Accelerator <-> Flash Memory
-------------------------------------------------------------------------------
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library work;
use work.AccTypes.all;
use work.common.all;

entity FlashCtrl is
    generic(
        FREQ            : integer := 80_000 -- in KHz
    );
    port (
        clk     	    : in  std_logic;						
        rst		        : in  std_logic;						
        flash_rdreq     : in std_logic;											
        flash_wreq      : in std_logic;						
        flash_rwaddr    : in std_logic_vector (FLASH_ADDR_WIDTH-1 downto 0);	
        flash_rdata     : out std_logic_vector (FLASH_BUS_WIDTH-1 downto 0);
        flash_wdata     : in std_logic_vector (FLASH_BUS_WIDTH-1 downto 0);
        flash_srst      : in std_logic;
        flash_op_valid  : out std_logic;					
        flash_ce_n	    : out std_logic;						
        flash_oe_n	    : out std_logic;						
        flash_we_n	    : out std_logic;
        flash_rp_n      : out std_logic;
        addr		    : out std_logic_vector (21 downto 0);	
        w_data		    : out std_logic_vector (15 downto 0);
        r_data		    : in std_logic_vector (15 downto 0)
    );
end FlashCtrl;

architecture rtl of FlashCtrl is


type StateType is (IDLE,READ_DATA,WRITE_DATA);

signal State            : StateType;
signal powerup_cnt      : unsigned(14 downto 0);
signal sreset_cnt       : unsigned(3 downto 0);
signal flash_rp_n_int   : std_logic;
signal cnt              : unsigned(3 downto 0);
signal flash_pwrup_done : std_logic;
signal flash_op_valid_int: std_logic;

begin

flash_rp_n <= flash_rp_n_int;
flash_op_valid <= flash_op_valid_int;

    Clock_enable_process:process(rst,clk)
    begin
        if rst='1' then
            flash_rp_n_int <= '0';
            powerup_cnt <= (others=>'0');
            sreset_cnt <= (others=>'0');
            flash_pwrup_done <= '0';
        elsif rising_edge(clk) then
            -- wait 300 us then set flash_rp_n_int ; then wait 50 us more and set flash_pwrup_done (ops can be executed then)
            flash_rp_n_int <= '0';
            if flash_srst='1' then
                sreset_cnt <= (others=>'0');
            end if;    
            if powerup_cnt > to_unsigned((4*FREQ/10),15) and sreset_cnt/=x"0" then
                flash_pwrup_done <= '1';
                flash_rp_n_int <= '1';
            elsif powerup_cnt > to_unsigned((3*FREQ/10),15) and sreset_cnt/=x"0" then 
                powerup_cnt <= powerup_cnt+1;
                flash_rp_n_int <= '1';
            else
                powerup_cnt <= powerup_cnt+1;
            end if;
            if sreset_cnt>x"B" then
                flash_rp_n_int <= '1';
            else
                flash_rp_n_int <= '0';
                sreset_cnt <= sreset_cnt+1;
            end if;        
        end if;    
    end process;
    
    SM:process(clk)
    begin
        if rising_edge(clk) then
            if rst='1' then
                state <= IDLE;
                addr <= (others=>'0');
                w_data <= (others=>'0');
                cnt <= (others=>'0');
                flash_rdata <= (others=>'0');
                flash_ce_n <= '1';
                flash_oe_n <= '1';
                flash_we_n <= '1';
                flash_op_valid_int <= '0';
            else
                if flash_pwrup_done='1' then
                    flash_ce_n <= '1';
                    flash_op_valid_int <= '0';
                    flash_we_n <= '1';
                    flash_oe_n <= '1';
                    case state is
                        when IDLE =>
                            if flash_op_valid_int='0' then
                                if flash_rdreq='1' then
                                    state <= READ_DATA;
                                    addr <= flash_rwaddr;
                                    flash_ce_n <= '0';
                                elsif flash_wreq='1' then
                                    state <= WRITE_DATA;
                                    addr <= flash_rwaddr;
                                    w_data <= flash_wdata;
                                    flash_ce_n <= '0';
                                end if;
                            end if;
                        when READ_DATA =>
                            flash_ce_n <= '0';
                            if cnt=x"6" then
                                flash_rdata <= r_data;
                                state <= IDLE;
                                flash_op_valid_int <= '1';
                                cnt <= (others=>'0');
                            else
                                cnt <= cnt+1;
                                flash_oe_n  <= '0';
                            end if;
                        when WRITE_DATA => 
                            w_data <= flash_wdata;
                            cnt <= cnt+1; 
                            flash_ce_n <= '0';                        
                            if cnt=x"4" then
                                state <= IDLE;
                                flash_op_valid_int <= '1';
                                cnt <= (others=>'0');
                            else
                                flash_we_n <= '0';
                            end if;
                        when others => 
                            state <= IDLE;
                            cnt <= (others=>'0');
                    end case;      
                end if;
            end if;        
        end if;
    end process;
    
end architecture rtl;
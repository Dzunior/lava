-------------------------------------------------------------------------------
--
-- File         : gen.vhd
-- Author       : Dominik Domanski
-- Date         : 27/03/10
--
-- Last Check-in :
-- $Revision: 3 $
-- $Author: dzunior $
-- $Date: 2010-03-28 22:33:07 +0200 (Sun, 28 Mar 2010) $
--
-------------------------------------------------------------------------------
-- Description:
-- Data generator
-------------------------------------------------------------------------------
library ieee;
use ieee.numeric_std.all;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;

library work;
use work.AccTypes.all;

entity gen is
    port (
        sclk            : in std_logic;
        rst             : in std_logic;
        mosi            : out std_logic;
        miso            : in std_logic
        );
end entity gen;

architecture rtl of gen is

    type StateType is  (POWER_UP,IDLE,WRITE_MEM,READ_MEM);
    signal state        : StateType;
    signal local_data: std_logic_vector (HOST_BUS_WIDTH-1 downto 0);
    signal vsync_n_prev,hsync_n_prev : std_logic;
    signal pixel_x,pixel_y : unsigned(7 downto 0);
    signal color : unsigned(2 downto 0);
    
begin

    process(rst,clk)
    begin
        if rst='1' then
            mosi <= (others=>'0');
            color <= (others=>'0');
        elsif rising_edge(clk) then
            if pixel_x/=x"FF" and pixel_y/=x"FF" then
                host_data_valid <= '1';
                pixel_x<= pixel_x+1;
                pixel_y<= pixel_y+1;
                host_data(18 downto 0) <= std_logic_vector(pixel_y(7 downto 5)&pixel_y&pixel_x);
            end if;    
        end if;
    end process;

end architecture rtl;
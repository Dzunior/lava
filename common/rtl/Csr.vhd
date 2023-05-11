-------------------------------------------------------------------------------
--
-- File         : Csr.vhd
-- Author       : Dominik Domanski
-- Date         : 29/03/10
--
-- Last Check-in :
-- $Revision: 59 $
-- $Author: dzunior $
-- $Date: 2010-08-12 20:43:06 +0200 (jue, 12 ago 2010) $
--
-------------------------------------------------------------------------------
-- Description:
-- Common registers
-------------------------------------------------------------------------------
library ieee;
use ieee.numeric_std.all;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;

library work;
use work.AccTypes.all;

entity Csr is
    port (
        rst           : in std_logic;
        clk           : in std_logic;
        addr          : in std_logic_vector (HOST_ADDR_WIDTH-1 downto 0);
        write_data    : in std_logic_vector (HOST_BUS_WIDTH-1 downto 0);
        read_data     : out std_logic_vector (HOST_BUS_WIDTH-1 downto 0);
        wnr           : in std_logic;
        engine_config : out EngineConfigRecord
        );
end entity Csr;

architecture rtl of Csr is

begin

    WRITE_REG:process (clk,rst) is
    begin
        if rst = '1' then
            engine_config <= ((others=>'0'),(others=>'0'),(others=>'0'));
            engine_config.color <= b"1101101010101011";
        elsif rising_edge(clk) then
            if wnr='1' then
                case addr is
                    when x"00" =>
                        engine_config.color <= write_data(engine_config.color'range);
                    when others => null;
                end case;
            end if;
        end if;
    end process WRITE_REG;


    READ_REG:process (clk,rst) is
    begin
        if rst = '1' then
            read_data <= (others=>'1');
        elsif rising_edge(clk) then
            if wnr='0' then
                case addr is
                    when x"00" => 
                        null;
                        --read_data <= BUILD_NUMBER;
                    when others =>
                        read_data <= (others=>'1');
                end case;
            end if;
        end if;
    end process READ_REG;

end architecture rtl;
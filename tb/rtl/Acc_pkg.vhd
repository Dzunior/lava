-------------------------------------------------------------------------------
--
-- File         : Acc_pkg.vhd
-- Author       : Dominik Domanski
-- Date         : 29/03/10
--
-- Last Check-in :
-- $Revision: 13 $
-- $Author: dzunior $
-- $Date: 2010-04-06 18:07:12 +0200 (mar, 06 abr 2010) $
--
-------------------------------------------------------------------------------
-- Description:
-- 
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library Acc;
use Acc.AccTypes.all;

package Acc_pkg is

    signal start                    : std_logic := '0';
    signal test_directory           : string(1 to 100);
    signal test_dir_len             : integer;

procedure read_reg(
    addr_val    : in integer;
    signal addr : out std_logic_vector(2 downto 0);
    signal req  : out std_logic;
    signal wnr  : out std_logic;
    signal ack  : in std_logic
   );

procedure write_reg(
    addr_val    : in integer;
    data_val    : in std_logic_vector(NO_CHANNELS-1 downto 0);
    signal addr : out std_logic_vector(2 downto 0);
    signal data : out std_logic_vector(NO_CHANNELS-1 downto 0);
    signal req  : out std_logic;
    signal wnr  : out std_logic;
    signal ack  : in std_logic
   );   
end package Acc_pkg;

package body Acc_pkg is

    procedure read_reg(
        addr_val    : in integer;
        signal addr : out std_logic_vector(2 downto 0);
        signal req  : out std_logic;
        signal wnr  : out std_logic;
        signal ack  : in std_logic
        ) is
    begin
        addr <= std_logic_vector(to_unsigned(addr_val,3));
        req <= '1';
        wnr <= '0';
        wait until ack='1';
        wait for 100 ns;
        req <= '0';
    end procedure read_reg;

    procedure write_reg(
        addr_val    : in integer;
        data_val    : in std_logic_vector(NO_CHANNELS-1 downto 0);
        signal addr : out std_logic_vector(2 downto 0);
        signal data : out std_logic_vector(NO_CHANNELS-1 downto 0);
        signal req  : out std_logic;
        signal wnr  : out std_logic;
        signal ack  : in std_logic
        ) is
    begin
        addr <= std_logic_vector(to_unsigned(addr_val,3));
        data <= data_val;
        req <= '1';
        wnr <= '1';
        wait until ack='1';
        wait for 100 ns;
        req <= '0';
    end procedure write_reg;   

end package body Acc_pkg;
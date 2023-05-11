-------------------------------------------------------------------------------
--
-- File         : SPI_gen.vhd
-- Author       : Dominik Domanski
-- Date         : 27/03/10
--
-- Last Check-in :
-- $Revision: 13 $
-- $Author: dzunior $
-- $Date: 2010-04-06 18:07:12 +0200 (Tue, 06 Apr 2010) $
--
-------------------------------------------------------------------------------
-- Description:
--  2D Engine is responsible for executing 2D operations.
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.AccTypes.all;
use work.common.all;

entity spi_gen is
    port (
        rst             : in  std_logic;  -- reset
        clk             : in  std_logic;  -- system clock
        sclk            : out std_logic;
        mosi            : out std_logic;
        miso            : in std_logic;
        ss_n            : out std_logic;
        hostctrl_full   : in std_logic;
        mem_ready_out   : in std_logic
        );
end entity spi_gen;

architecture rtl of spi_gen is

constant DRAW_POINT : std_logic_vector(3 downto 0):=x"1";
constant COPY_BUFFER: std_logic_vector(3 downto 0):=x"4";
type StateType is (IDLE,WRITE_DATA,CHANGE_CLOCK);
signal state : StateType;
signal delay : unsigned(15 downto 0);
signal pixel_x,pixel_y : unsigned(9 downto 0);
signal color : unsigned(15 downto 0);
signal bit_position : unsigned(3 downto 0);
signal parameter0,parameter1,parameter2 : std_logic_vector(15 downto 0);
signal word : unsigned(1 downto 0);
signal command : std_logic_vector(3 downto 0);
signal mem_type : std_logic;
begin

U_spi_gen:process(clk,rst)
    begin
        if rst='1' then
            state <= IDLE;
            delay <= (others=>'0');
            pixel_x <= (others=>'0');
            pixel_y <= (others=>'0');
            color   <= (others=>'1');
            ss_n    <= '1';
            bit_position <= (others=>'1');
            sclk <= '1';
            parameter0 <= (others=>'0');
            parameter1 <= (others=>'0');
            parameter2 <= (others=>'0');
            word <=(others=>'0');
            command <= WRITE_MEM;
            mem_type <= '0';
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    if hostctrl_full='0' then --and mem_ready_out='1' then
                        if delay = x"00FF" then
                            state <= WRITE_DATA;
                            parameter0<= command&b"000"&mem_type&x"0"&std_logic_vector(pixel_y(9 downto 6));
                            parameter1<= std_logic_vector(pixel_y(5 downto 0))&std_logic_vector(pixel_x);
                            parameter2<= std_logic_vector(pixel_y(5 downto 0))&std_logic_vector(pixel_x);
                            ss_n    <= '0';
                        else
                            state <= IDLE;
                            delay <= delay+1;
                        end if;
                    else
                        state <= IDLE;
                    end if;    
                when WRITE_DATA =>
                    if hostctrl_full='0' then
                        case word is
                            when b"00" =>
                                mosi <= parameter0(to_integer(bit_position));
                            when b"01" =>
                                mosi <= parameter1(to_integer(bit_position));
                            when others =>
                                mosi <= parameter2(to_integer(bit_position));
                        end case;
                        state <= CHANGE_CLOCK;
                        sclk <= '0';
                    end if;        
                when CHANGE_CLOCK =>
                    if bit_position=x"0" then
                        bit_position <= (others=>'1');
                        if word=b"10" then
                            word <= (others=>'0');
                            state <= IDLE;
                            delay <= (others=>'0');
                            if pixel_x=x"031F" then
                                if pixel_y=x"0257" then
                                    pixel_y <= (others=>'0');
                                else
                                    pixel_y <= pixel_y+1;
                                end if;
                                pixel_x <= (others=>'0');
                            else
                                pixel_x <= pixel_x+1;
                            end if;  
                        else
                            word <= word+1;
                            state <= WRITE_DATA;
                        end if;    
                    else
                        bit_position<= bit_position-1;
                        state <= WRITE_DATA;
                    end if;  
                    sclk <= '1'; 
                when others =>
                    null;
            end case;  
        end if;    
    end process;
    
end architecture rtl;
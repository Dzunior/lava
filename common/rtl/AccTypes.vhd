-------------------------------------------------------------------------------
--
-- File         : AccTypes.vhd
-- Author       : Dominik Domanski
-- Date         : 29/03/10
--
-- Last Check-in :
-- $Revision: 130 $
-- $Author: dzunior $
-- $Date: 2010-10-26 17:42:29 +0200 (mar, 26 oct 2010) $
--
-------------------------------------------------------------------------------
-- Description:
-- Functions,Types,constants,records etc. used in the design.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package AccTypes is
    
    constant CLK_FREQ               : integer := 80_000 ; -- in KHz
    constant FLASH_ADDR_WIDTH       : integer := 22;
    constant FLASH_BUS_WIDTH        : integer := 16;
    constant HOST_BUS_WIDTH         : integer := 16;
    constant HOST_ADDR_WIDTH        : integer := 8;
    constant DISPLAY_BUS_WIDTH      : integer := 16;
    constant PIXEL_BUFFER_DEPTH     : integer := 256;
    constant PIXEL_BUFFER_WIDTH     : integer := 16;
    constant PIXEL_BUFFER_RDUSEDW   : integer := 8;
    constant PIXEL_BUFFER_WRUSEDW   : integer := 8;
    constant NUM_RGB_BITS           : integer := 5; 
    constant X_RESOLUTION           : integer := 800;
    constant Y_RESOLUTION           : integer := 600;
    constant X_RES_SIZE             : integer := 10; -- log2(X_RESOLUTION)
    constant Y_RES_SIZE             : integer := 10; -- log2(Y_RESOLUTION)
    constant BPP_COLOR              : integer := 5;
    constant MEM_DATA_WIDTH         : integer := 16;
    constant PIXEL_POINTER          : integer := 8; -- MEMORY_DATA_WIDTH/BPP_COLOR -- I guess it should be modified in the future
    constant HADDR_WIDTH            : natural := 24;  -- host-side address width
    constant SADDR_WIDTH            : natural := 13;  -- SDRAM-side address width
    constant BUILD_NUMBER           : std_logic_vector(HOST_BUS_WIDTH-1 downto 0):=x"0100";
    constant PIXEL_WIDTH            : natural := 16;
    constant TOTAL_PIXEL_NUMBER     : integer :=800600; 
    -- Commands
    constant MEM_COPY               : std_logic_vector(3 downto 0):=x"1";
    constant WRITE_MEM              : std_logic_vector(3 downto 0):=x"2";
    constant READ_MEM               : std_logic_vector(3 downto 0):=x"3";
    constant TEXT_STRING            : std_logic_vector(3 downto 0):=x"4";
    -- CSR regs
    constant CSR_COLOR              : unsigned(3 downto 0):=x"0";
    constant CSR_FONT_X             : unsigned(3 downto 0):=x"1";
    constant CSR_FONT_Y             : unsigned(3 downto 0):=x"2";
    constant TRANSPARENCY           : unsigned(3 downto 0):=x"3";
    constant BUFFER_REG             : unsigned(3 downto 0):=x"4";
    constant BUILD_VERSION          : unsigned(3 downto 0):=x"5";
    constant CONFIG_REG             : unsigned(3 downto 0):=x"6";
    -- command data size
    constant MEM_COPY_SIZE          : integer:=5;
    constant WRITE_MEM_SIZE		    : integer:=3;
    constant READ_MEM_SIZE		    : integer:=2;
    constant CMD_SIZE               : integer:=4;
    -- buffers
    constant PRIMARY_BUFFER         : std_logic:='0';
    constant BACK_BUFFER            : std_logic:='1';
    -- Memory type
    constant SDRAM                  : std_logic:='0';
    constant FLASH                  : std_logic:='1'; 
    
type EngineConfigRecord is record
    color   : std_logic_vector(MEM_DATA_WIDTH-1 downto 0);
    font_x  : unsigned(X_RES_SIZE-1 downto 0);
    font_y  : unsigned(Y_RES_SIZE-1 downto 0);
end record;

subtype CmdRange is natural range HOST_BUS_WIDTH-1 downto HOST_BUS_WIDTH-CMD_SIZE; -- top 4 bits = contains info about the command
subtype DrawDataRange is natural range Y_RES_SIZE+X_RES_SIZE+MEM_DATA_WIDTH-1 downto 0;
subtype ParametersArrayRange is natural range 0 to 6;
type ParametersArray is array (ParametersArrayRange) of unsigned(HOST_BUS_WIDTH-1 downto 0);
subtype DrawAddrRange is natural range DrawDataRange'high downto DrawDataRange'high-X_RES_SIZE-Y_RES_SIZE+1;
subtype XpixelRange is natural range X_RES_SIZE-1 downto 0;
subtype YpixelRange is natural range Y_RES_SIZE+X_RES_SIZE-1 downto X_RES_SIZE;
subtype PixelRange is natural range Y_RES_SIZE+X_RES_SIZE-1 downto 0;
-- Calclates the address of pixel(x,y)
function pixel_addr(x : in unsigned; y : in unsigned ) return std_logic_vector;

end package AccTypes;

package body AccTypes is

-- Calclates the address of pixel(x,y)
function pixel_addr(x : in unsigned; y : in unsigned ) return std_logic_vector is
    variable address: std_logic_vector(Y_RES_SIZE+X_RES_SIZE-1 downto 0);
begin
    address := std_logic_vector(y*X_RESOLUTION+x);
    return address;
end function pixel_addr;

-- function addr_calc(ptr_x : in unsigned; ptr_y : in unsigned; min_x: in unsigned; max_x : in unsigned;
                   -- min_y : in unsigned; max_y : in unsigned;  ) return unsigned is
-- begin
    -- if ptr_x=max_x then
        -- ptr_y<=ptr_y+1;
        -- ptr_x<=min_x;
    -- else
        -- ptr_x<=ptr_x+1;
    -- end if;
                   
-- end function addr_calc;
  
end package body AccTypes;
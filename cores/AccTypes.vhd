-------------------------------------------------------------------------------
--
-- File         : AccTypes.vhd
-- Author       : Dominik Domanski
-- Date         : 29/03/10
--
-- Last Check-in :
-- $Revision: 32 $
-- $Author: dzunior $
-- $Date: 2010-07-19 11:42:57 +0200 (lun, 19 jul 2010) $
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
    constant HOST_BUS_WIDTH         : integer := 16;
    constant HOST_ADDR_WIDTH        : integer := 8;
    constant DISPLAY_BUS_WIDTH      : integer := 16;
    constant PIXEL_BUFFER_DEPTH     : integer := 256;
    constant PIXEL_BUFFER_WIDTH     : integer := 16;
    constant PIXEL_BUFFER_RDUSEDW   : integer := 8;
    constant PIXEL_BUFFER_WRUSEDW   : integer := 8;
    constant NUM_RGB_BITS           : integer := 3; 
    constant X_RESOLUTION           : integer := 800;
    constant Y_RESOLUTION           : integer := 600;
    constant X_RES_SIZE             : integer := 10; -- log2(X_RESOLUTION)
    constant Y_RES_SIZE             : integer := 10; -- log2(Y_RESOLUTION)
    constant BPP_COLOR              : integer := 3;
    constant COLOR_DATA             : integer := 9;
    constant MEM_DATA_WIDTH         : integer := 16;
    constant PIXEL_POINTER          : integer := 8; -- MEMORY_DATA_WIDTH/BPP_COLOR -- I guess it should be modified in the future
    constant HADDR_WIDTH            : natural := 24;  -- host-side address width
    constant SADDR_WIDTH            : natural := 13;  -- SDRAM-side address width
    constant BUILD_NUMBER           : std_logic_vector(HOST_BUS_WIDTH-1 downto 0):=x"0001";
    constant DISPLAY_FREQ           : natural := 80_000;
    constant PIXEL_WIDTH            : natural := 16;
    -- Commands
    constant CLEAR_SCREEN           : std_logic_vector(3 downto 0):=x"0";
    constant DRAW_POINT             : std_logic_vector(3 downto 0):=x"1";
    constant DRAW_LINE              : std_logic_vector(3 downto 0):=x"2";
    constant DRAW_RECTANGLE         : std_logic_vector(3 downto 0):=x"3";
	constant BLITTER           		: std_logic_vector(3 downto 0):=x"4";
    constant FILLED                 : std_logic:='1';
    constant NOT_FILLED             : std_logic:='0';
    -- command data size
    constant POINT_DATA_SIZE        : integer:=2;
    constant LINE_DATA_SIZE         : integer:=4;
    constant RECTANGLE_DATA_SIZE    : integer:=4;
    -- modes for line drawing 
    constant X_DOMINANT             : std_logic:='0';
    constant Y_DOMINANT             : std_logic:='1';
    constant CMD_SIZE               : integer:=4;
    -- buffers
    constant PRIMARY_BUFFER         : std_logic:='0';
    constant BACK_BUFFER            : std_logic:='1';
    
type EngineConfigRecord is record
    color  : std_logic_vector(MEM_DATA_WIDTH-1 downto 0);
end record;

subtype CmdRange is natural range HOST_BUS_WIDTH-1 downto HOST_BUS_WIDTH-CMD_SIZE; -- 4 bits = contains info about the command
subtype DrawDataRange is natural range Y_RES_SIZE+X_RES_SIZE+MEM_DATA_WIDTH-1 downto 0;
type ParametersArray is array (0 to 3) of unsigned(X_RES_SIZE-1 downto 0);
subtype DrawAddrRange is natural range DrawDataRange'high downto DrawDataRange'high-X_RES_SIZE-Y_RES_SIZE+1;

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
  
end package body AccTypes;
-------------------------------------------------------------------------------
--
-- File         : Acc_tb_pkg.vhd
-- Author       : Dominik Domanski
-- Date         : 29/03/10
--
-- Last Check-in :
-- $Revision: 13 $
-- $Author: dzunior $
-- $Date: 2010-04-06 18:07:12 +0200 (Tue, 06 Apr 2010) $
--
-------------------------------------------------------------------------------
-- Description:
-- 
-------------------------------------------------------------------------------
library std;
use std.textio.all;

library std_developerskit;
use std_developerskit.std_iopak.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

library work;
use work.AccTbTypes.all;

library Acc;
use Acc.AccTypes.all;
use Acc.common.all;

package Acc_tb_pkg is

    -- type RegTransaction is record
        -- initRd  : std_logic;
        -- initWr  : std_logic;
        -- accept  : std_logic;
        -- data    : std_logic_vector(15 downto 0);
    -- end record;
    
    signal start                    : std_logic := '0';
    signal test_directory           : string(1 to 100);
    signal test_dir_len             : integer;
    signal error_counter            : natural:= 0;
    signal read_data                : std_logic_vector(15 downto 0);
    shared variable enable_timeout  : boolean := false;
    shared variable test_finished   : std_logic:='0';
    signal regH                     : RegTransaction:=('0','0','Z',(others=>'0'));
    
    constant CORE_CLK_PERIOD        : time :=13.333 ns; 
    constant DISPLAY_CLK_PERIOD     : time :=25 ns; 
    constant SCLK_PERIOD            : time:=55 ns;
    
procedure LOG(l: in string);

procedure finish;
    
procedure read_reg(
    addr_val    : in integer;
    signal addr : out std_logic_vector(2 downto 0);
    signal req  : out std_logic;
    signal wnr  : out std_logic;
    signal ack  : in std_logic
   );

    procedure data_write(
        signal reg_trx : inout RegTransaction;
        data : in std_logic_vector(15 downto 0)
    );
    
    -- procedure data_read(
        -- signal reg_trx : inout RegTransaction;
        -- signal data : out std_logic_vector(15 downto 0)
    -- );
    
-- procedure write_reg(
    -- addr_val    : in integer;
    -- data_val    : in std_logic_vector(NO_CHANNELS-1 downto 0);
    -- signal addr : out std_logic_vector(2 downto 0);
    -- signal data : out std_logic_vector(NO_CHANNELS-1 downto 0);
    -- signal req  : out std_logic;
    -- signal wnr  : out std_logic;
    -- signal ack  : in std_logic
   -- );  

procedure draw_point( 
    signal regH : inout RegTransaction;
    pixel_x     : in integer;
    pixel_y     : in integer
    );

procedure draw_line( 
    signal regH : inout RegTransaction;
    pixel_x1    : in std_logic_vector(X_RES_SIZE-1 downto 0);
    pixel_y1    : in std_logic_vector(Y_RES_SIZE-1 downto 0);
    pixel_x2    : in std_logic_vector(X_RES_SIZE-1 downto 0);
    pixel_y2    : in std_logic_vector(Y_RES_SIZE-1 downto 0)
    );

procedure draw_rectangle(
    signal regH : inout RegTransaction;
    pixel_x1    : in std_logic_vector(X_RES_SIZE-1 downto 0);
    pixel_y1    : in std_logic_vector(Y_RES_SIZE-1 downto 0);
    pixel_x2    : in std_logic_vector(X_RES_SIZE-1 downto 0);
    pixel_y2    : in std_logic_vector(Y_RES_SIZE-1 downto 0)
    );

procedure draw_buffer(
    signal regH : inout RegTransaction
    );

procedure copy_block(
    signal regH : inout RegTransaction;
    src_addr    : in std_logic_vector(HADDR_WIDTH-1 downto 0);
    pixel_x1    : in std_logic_vector(X_RES_SIZE-1 downto 0);
    pixel_y1    : in std_logic_vector(Y_RES_SIZE-1 downto 0);
    pixel_x2    : in std_logic_vector(X_RES_SIZE-1 downto 0);
    pixel_y2    : in std_logic_vector(Y_RES_SIZE-1 downto 0)
    );

procedure draw_text(
    signal regH         : inout RegTransaction;
    constant text_length: in integer;
    constant char_string: in string
    );

procedure csr(
    signal regH         : inout RegTransaction;
    constant addr       : in std_logic_vector;
    constant data       : in std_logic_vector
    );

procedure read_memory(
    signal regH         : inout RegTransaction;
    constant addr       : in std_logic_vector
    );
    
procedure write_memory(
    signal regH         : inout RegTransaction;
    constant addr       : in std_logic_vector;
    constant data       : in std_logic_vector
    );   
    
end package Acc_tb_pkg;

package body Acc_tb_pkg is

    ---------------------------------------------------------------------
    -- Displays a message
    ---------------------------------------------------------------------
    procedure LOG(l: in string) is
        variable outline:LINE;
    begin
        WRITE(outline,'(');
        WRITE(outline,now);
        WRITE(outline,string'(") "));
        WRITE(outline,string'(l));
        WRITELINE(output,outline);
    end LOG;    
    --------------------------------------------------------------------- 
    -- Terminates the simulation
    ---------------------------------------------------------------------   
    procedure finish is
    begin
        wait for 3000 ns;
        test_finished:='1';        
        if (error_counter>0) then
            report CR & CR & "**************" & CR & " TEST FAILED!" & CR & to_string(error_counter, "%4d")
                & " errors" & CR & "**************" & CR severity failure;
        else
            report CR & CR & "**************" & CR & "TEST PASSED!" & CR 
            & "**************" & CR severity failure;
        end if;
    end finish;  
    
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

    procedure data_write(
        signal reg_trx : inout RegTransaction;
        data : in std_logic_vector(15 downto 0)
        ) is
        variable outline : LINE;
    begin
        -- pad register out with zeros
        --reg_trx.data <= (others => '0');
        reg_trx.data<=data;
        reg_trx.data(3 downto 0)<=x"6";
        reg_trx.initWr<='1';
        reg_trx.accept <= 'Z';
        wait until reg_trx.accept='1';
        reg_trx.initWr<='0';
        WRITE(outline,'(');WRITE(outline,now);WRITE(outline,string'(") "));
        WRITE(outline,string'("fpga <= CPU : data="));HWRITE(outline,data);WRITELINE(output,outline);
    end procedure;
    
    -- procedure data_read(
        -- signal reg_trx : inout RegTransaction;
        -- signal data    : out std_logic_vector(15 downto 0)
        -- ) is
        -- variable outline : LINE;
    -- begin
        -- reg_trx.initRd<='1';
        -- reg_trx.accept <= 'Z';
        -- wait until reg_trx.accept='1';
        -- data<=reg_trx.data;
        -- reg_trx.initRd<='0';
        -- WRITE(outline,'(');WRITE(outline,now);WRITE(outline,string'(") "));
        -- WRITE(outline,string'("fpga => CPU : data="));HWRITE(outline,reg_trx.data);WRITELINE(output,outline);
    -- end procedure;
    
    -- procedure write_reg(
        -- addr_val    : in integer;
        -- data_val    : in std_logic_vector(NO_CHANNELS-1 downto 0);
        -- signal addr : out std_logic_vector(2 downto 0);
        -- signal data : out std_logic_vector(NO_CHANNELS-1 downto 0);
        -- signal req  : out std_logic;
        -- signal wnr  : out std_logic;
        -- signal ack  : in std_logic
        -- ) is
    -- begin
        -- addr <= std_logic_vector(to_unsigned(addr_val,3));
        -- data <= data_val;
        -- req <= '1';
        -- wnr <= '1';
        -- wait until ack='1';
        -- wait for 100 ns;
        -- req <= '0';
    -- end procedure write_reg;   

    procedure draw_point( 
    signal regH : inout RegTransaction;
    pixel_x     : in integer;
    pixel_y     : in integer
    ) is
    variable outline:LINE;
    begin 
        WRITE(outline,string'("DRAW_POINT : x="));HWRITE(outline,(b"000000"&std_logic_vector(to_unsigned(pixel_x,X_RES_SIZE))));
        WRITE(outline,string'(" y="));HWRITE(outline,(b"000000"&std_logic_vector(to_unsigned(pixel_y,X_RES_SIZE))));WRITELINE(output,outline);
        data_write(regH,x"1"&b"00"&std_logic_vector(to_unsigned(pixel_x,X_RES_SIZE)));
        data_write(regH,x"0"&b"00"&std_logic_vector(to_unsigned(pixel_y,X_RES_SIZE)));
    end procedure;
    
    procedure draw_line( 
    signal regH : inout RegTransaction;
    pixel_x1    : in std_logic_vector(X_RES_SIZE-1 downto 0);
    pixel_y1    : in std_logic_vector(Y_RES_SIZE-1 downto 0);
    pixel_x2    : in std_logic_vector(X_RES_SIZE-1 downto 0);
    pixel_y2    : in std_logic_vector(Y_RES_SIZE-1 downto 0)
    ) is
    variable outline:LINE;
    begin 
        WRITE(outline,string'("DRAW_LINE : x1="));HWRITE(outline,(b"000000"&pixel_x1));
        WRITE(outline,string'(" y1="));HWRITE(outline,(b"000000"&pixel_y1));
        WRITE(outline,string'(" x2="));HWRITE(outline,(b"000000"&pixel_x2));
        WRITE(outline,string'(" y2="));HWRITE(outline,(b"000000"&pixel_y2));WRITELINE(output,outline);
        data_write(regH,x"2"&b"00"&pixel_x1);
        data_write(regH,x"0"&b"00"&pixel_y1);
        data_write(regH,b"000000"&pixel_x2);
        data_write(regH,b"000000"&pixel_y2);
    end procedure;
    
    procedure draw_rectangle(
    signal regH : inout RegTransaction;
    pixel_x1    : in std_logic_vector(X_RES_SIZE-1 downto 0);
    pixel_y1    : in std_logic_vector(Y_RES_SIZE-1 downto 0);
    pixel_x2    : in std_logic_vector(X_RES_SIZE-1 downto 0);
    pixel_y2    : in std_logic_vector(Y_RES_SIZE-1 downto 0)
    ) is
    variable outline:LINE;
    begin 
        WRITE(outline,string'("DRAW_RECTANGLE : x1="));HWRITE(outline,(b"000000"&pixel_x1));
        WRITE(outline,string'(" y1="));HWRITE(outline,(b"000000"&pixel_y1));
        WRITE(outline,string'(" x2="));HWRITE(outline,(b"000000"&pixel_x2));
        WRITE(outline,string'(" y2="));HWRITE(outline,(b"000000"&pixel_y2));WRITELINE(output,outline);
        data_write(regH,x"3"&b"00"&pixel_x1);
        data_write(regH,x"0"&b"00"&pixel_y1);
        data_write(regH,b"000000"&pixel_x2);
        data_write(regH,b"000000"&pixel_y2);
    end procedure;
    
    procedure draw_buffer(
    signal regH : inout RegTransaction
    ) is
    variable outline:LINE;
    begin
        WRITE(outline,string'("DRAW_BUFFER"));WRITELINE(output,outline);
        data_write(regH,x"4"&x"000");
    end procedure;
    
    procedure copy_block(
    signal regH : inout RegTransaction;
    src_addr    : in std_logic_vector(HADDR_WIDTH-1 downto 0);
    pixel_x1    : in std_logic_vector(X_RES_SIZE-1 downto 0);
    pixel_y1    : in std_logic_vector(Y_RES_SIZE-1 downto 0);
    pixel_x2    : in std_logic_vector(X_RES_SIZE-1 downto 0);
    pixel_y2    : in std_logic_vector(Y_RES_SIZE-1 downto 0)
    ) is
    variable outline:LINE;
    begin 
        WRITE(outline,string'("COPY_BLOCK : source address="));HWRITE(outline,src_addr);
        WRITE(outline,string'(" x1="));HWRITE(outline,(b"000000"&pixel_x1));
        WRITE(outline,string'(" y1="));HWRITE(outline,(b"000000"&pixel_y1));
        WRITE(outline,string'(" x2="));HWRITE(outline,(b"000000"&pixel_x2));
        WRITE(outline,string'(" y2="));HWRITE(outline,(b"000000"&pixel_y2));WRITELINE(output,outline);
        data_write(regH,x"5"&x"0"&src_addr(HADDR_WIDTH-1 downto HADDR_WIDTH-8));
        data_write(regH,src_addr(HOST_BUS_WIDTH-1 downto 0));
        data_write(regH,x"0"&b"00"&pixel_y1);
        data_write(regH,b"000000"&pixel_x2);
        data_write(regH,b"000000"&pixel_y2);
    end procedure;
    
    procedure draw_text(
    signal regH         : inout RegTransaction;
    constant text_length  : in integer;
    constant char_string  : in string
    -- signal char_1       : Character;
    -- signal char_2       : Character;
    -- signal char_3       : Character;
    -- signal char_4       : Character;
    -- signal char_5       : Character;
    -- signal char_6       : Character;
    -- signal char_7       : Character;
    -- signal char_8       : Character;
    -- signal char_9       : Character
    ) is 
    variable outline:LINE;
    --variable text_length_integer : integer;
    begin
        --text_length_integer := to_integer(unsigned(text_length));
        WRITE(outline,string'("DRAW_TEXT : "));
        WRITE(outline,string'(" text_length="));HWRITE(outline,(std_logic_vector(to_unsigned(text_length,4))));
        WRITELINE(output,outline);
        data_write(regH,TEXT_STRING&x"00"&std_logic_vector(to_unsigned(text_length,4)));
        for i in 0 to text_length/2 loop
            data_write(regH,CONV_STD_LOGIC_VECTOR(character'pos(char_string(i*2+1)),8)&CONV_STD_LOGIC_VECTOR(character'pos(char_string((i*2)+2)),8));
        end loop;    
    end procedure;
    
    procedure csr(
    signal regH         : inout RegTransaction;
    constant addr       : in std_logic_vector;
    constant data       : in std_logic_vector
    ) is
    variable outline:LINE;
    begin
        WRITE(outline,string'("CSR : "));
        WRITE(outline,string'(" addr="));HWRITE(outline,addr);
        WRITE(outline,string'(" data="));HWRITE(outline,data);WRITELINE(output,outline);
        data_write(regH,CSR_COMMAND&x"00"&addr);
        data_write(regH,data);
    end procedure;
   
    procedure read_memory(
        signal regH         : inout RegTransaction;
        constant addr       : in std_logic_vector
    ) is
    variable outline:LINE;
    begin
        WRITE(outline,string'("READ_MEMORY : "));
        WRITE(outline,string'(" addr="));HWRITE(outline,addr);
        WRITELINE(output,outline);
        data_write(regH,x"7"&x"0"&addr(23 downto 16));
        data_write(regH,addr(15 downto 0));
        --WRITE(outline,string'(" data="));HWRITE(outline,data);WRITELINE(output,outline);
    end procedure;
    
    procedure write_memory(
        signal regH         : inout RegTransaction;
        constant addr       : in std_logic_vector;
        constant data       : in std_logic_vector
    ) is
    variable outline:LINE;
    begin
        WRITE(outline,string'("READ_MEMORY : "));
        WRITE(outline,string'(" addr="));HWRITE(outline,addr);
        WRITE(outline,string'(" data="));HWRITE(outline,data);
        WRITELINE(output,outline);
        data_write(regH,x"6"&x"0"&addr(23 downto 16));
        data_write(regH,addr(15 downto 0));
        data_write(regH,data);
    end procedure;
    
end package body Acc_tb_pkg;
-------------------------------------------------------------------------------
--
-- File         : Acc_tb_pkg.vhd
-- Author       : Dominik Domanski
-- Date         : 29/03/10
--
-- Last Check-in :
-- $Revision: 138 $
-- $Author: dzunior $
-- $Date: 2010-10-27 20:09:58 +0200 (mié, 27 oct 2010) $
--
-------------------------------------------------------------------------------
-- Description:
-- 
-------------------------------------------------------------------------------


library std;
use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library std_developerskit;
use std_developerskit.std_iopak.all;
 
library Acc;
use Acc.AccTypes.all;
use Acc.common.all;

package Acc_tb_pkg is

    type RegTransaction is record
        initRd  : std_logic;
        initWr  : std_logic;
        accept  : std_logic;
        Wrdata  : std_logic_vector(15 downto 0);
        Rddata  : std_logic_vector(15 downto 0);
    end record;
    
    signal start                    : std_logic := '0';
    signal test_directory           : string(1 to 100);
    signal test_dir_len             : integer;
    shared variable error_counter   : natural:= 0;
    shared variable enable_timeout  : boolean := false;
    shared variable test_finished   : std_logic:='0';
    signal regH                     : RegTransaction:=('0','0','Z',(others=>'0'),(others=>'Z'));
    
    constant CORE_CLK_PERIOD        : time :=13.333 ns; 
    constant DISPLAY_CLK_PERIOD     : time :=25 ns; 
    constant SCLK_PERIOD            : time:=100 ns;
    
procedure LOG(l: in string);

procedure finish;

    procedure data_write(
        signal reg_trx : inout RegTransaction;
        data : in unsigned(15 downto 0)
    );
    
    procedure data_read(
        signal reg_trx : inout RegTransaction;
        variable data  : out unsigned(15 downto 0)
    );

procedure mem_copy(
    signal regH : inout RegTransaction;
    src_mem     : in std_logic;    
    dst_mem     : in std_logic;
    src_addr    : in unsigned(HADDR_WIDTH-1 downto 0);    
    dst_addr    : in unsigned(HADDR_WIDTH-1 downto 0);
    copy_length : in integer
    );
    
procedure draw_text(
    signal regH         : inout RegTransaction;
    constant text_length: in integer;
    constant char_string: in string
    );


procedure read_memory(
    signal regH         : inout RegTransaction;
    constant mem        : in std_logic;
    constant csr        : in std_logic;
    constant rnw        : in std_logic;
    constant addr       : in unsigned(23 downto 0);
    variable data       : out unsigned(15 downto 0)
    );
    
procedure write_memory(
    signal regH         : inout RegTransaction;
    constant mem        : in std_logic;
    constant csr        : in std_logic;
    constant rnw        : in std_logic;
    constant addr       : in unsigned(23 downto 0);
    constant data       : in unsigned
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

    procedure data_write(
        signal reg_trx : inout RegTransaction;
        data : in unsigned(15 downto 0)
        ) is
        variable outline : LINE;
    begin
        -- pad register out with zeros
        reg_trx.Wrdata <= (others =>'0');
        reg_trx.Wrdata<=std_logic_vector(data);
        reg_trx.initWr<='1';
        reg_trx.accept <= 'Z';
        wait until reg_trx.accept='1';
        reg_trx.initWr<='0';
        WRITE(outline,'(');WRITE(outline,now);WRITE(outline,string'(") "));
        WRITE(outline,string'("fpga <= CPU : data="));HWRITE(outline,slv(data));WRITELINE(output,outline);
    end procedure;
    
    procedure data_read(
        signal reg_trx : inout RegTransaction;
        variable data  : out unsigned(15 downto 0)
        ) is
        variable outline : LINE;
    begin
        reg_trx.initRd<='1';
        reg_trx.accept <= 'Z';
        wait until reg_trx.accept='1';
        data:=unsigned(reg_trx.Rddata);
        reg_trx.initRd<='0';
        WRITE(outline,'(');WRITE(outline,now);WRITE(outline,string'(") "));
        WRITE(outline,string'("fpga => CPU : data="));HWRITE(outline,reg_trx.Rddata);WRITELINE(output,outline);
    end procedure;

    procedure mem_copy(
    signal regH : inout RegTransaction;
    src_mem     : in std_logic;    
    dst_mem     : in std_logic;
    src_addr    : in unsigned(HADDR_WIDTH-1 downto 0);    
    dst_addr    : in unsigned(HADDR_WIDTH-1 downto 0);
    copy_length : in integer
    ) is
    variable outline:LINE;
    begin
        if src_mem=SDRAM then
            WRITE(outline,string'("mem_mem_copy : src mem type=SDRAM"));
        else
            WRITE(outline,string'("mem_mem_copy : src mem type=FLASH"));
        end if;        
        WRITE(outline,string'(" source address=x"));HWRITE(outline,slv(src_addr));WRITELINE(output,outline);
        if dst_mem=SDRAM then
            WRITE(outline,string'("mem_mem_copy : dst mem type=SDRAM"));
        else
            WRITE(outline,string'("mem_mem_copy : dst mem type=FLASH"));
        end if;
        WRITE(outline,string'(" destination address=x"));HWRITE(outline,slv(dst_addr));
        WRITELINE(output,outline);
        WRITE(outline,string'("length="));WRITE(outline,copy_length);WRITELINE(output,outline);
        data_write(regH,x"1"&b"000"&src_mem&src_addr(HADDR_WIDTH-1 downto HADDR_WIDTH-8));
        data_write(regH,src_addr(HOST_BUS_WIDTH-1 downto 0));
        data_write(regH,to_unsigned(copy_length,16));
        data_write(regH,x"0"&b"000"&dst_mem&dst_addr(HADDR_WIDTH-1 downto HADDR_WIDTH-8));
        data_write(regH,dst_addr(HOST_BUS_WIDTH-1 downto 0));
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
        data_write(regH,unsigned(TEXT_STRING&x"00"&slv(to_unsigned(text_length,4))));
        for i in 0 to (text_length/2-1) loop
            data_write(regH,unsigned(slv(to_unsigned(character'pos(char_string(i*2+1)),8))&slv(to_unsigned(character'pos(char_string((i*2)+2)),8))));
        end loop;    
    end procedure;
   
    procedure read_memory(
        signal regH         : inout RegTransaction;
        constant mem        : in std_logic;
        constant csr        : in std_logic;
        constant rnw        : in std_logic;
        constant addr       : in unsigned(23 downto 0);
        variable data       : out unsigned(15 downto 0)
    ) is
    variable outline:LINE;
    begin
        if mem=SDRAM then
            WRITE(outline,string'("READ_MEMORY : mem type=SDRAM"));
        else
            WRITE(outline,string'("READ_MEMORY : mem type=FLASH"));
        end if; 
        WRITE(outline,string'(" addr="));HWRITE(outline,slv(addr));
        WRITELINE(output,outline);
        data_write(regH,x"3"&'0'&rnw&csr&mem&addr(23 downto 16));
        data_write(regH,addr(15 downto 0));
        data_read(regH,data);
        WRITE(outline,string'(" data="));HWRITE(outline,regH.Rddata);WRITELINE(output,outline);
    end procedure;
    
    procedure write_memory(
        signal regH         : inout RegTransaction;
        constant mem        : in std_logic;
        constant csr        : in std_logic;
        constant rnw        : in std_logic;
        constant addr       : in unsigned(23 downto 0);
        constant data       : in unsigned
    ) is
    variable outline:LINE;
    begin
        if mem=SDRAM then
            WRITE(outline,string'("WRITE_MEMORY : mem type=SDRAM"));
        else
            WRITE(outline,string'("WRITE_MEMORY : mem type=FLASH"));
        end if; 
        WRITE(outline,string'(" addr="));HWRITE(outline,slv(addr));
        WRITE(outline,string'(" data="));HWRITE(outline,slv(data));
        WRITELINE(output,outline);
        data_write(regH,x"2"&'0'&rnw&csr&mem&addr(23 downto 16));
        data_write(regH,addr(15 downto 0));
        data_write(regH,data);
    end procedure;
    
end package body Acc_tb_pkg;
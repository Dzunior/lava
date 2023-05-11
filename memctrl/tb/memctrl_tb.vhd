-------------------------------------------------------------------------------
--
-- File         : memctrl_tb.vhd
-- Author       : Dominik Domanski
-- Date         : 09/07/10
--
-- Last Check-in :
-- $Revision: 107 $
-- $Author: dzunior $
-- $Date: 2010-09-25 01:42:35 +0200 (sáb, 25 sep 2010) $
--
-------------------------------------------------------------------------------
-- Description:
-- simple test for sdramctrl.vhd
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library std;
use std.textio.all;
use WORK.common.all;

-- library GS_random;
-- use GS_random.rng2.all;

entity memctrl_tb is
end memctrl_tb;

architecture tb of memctrl_tb is

constant SYS_CLK_PERIOD : time:=12.5 ns;
constant DATA_WIDTH     : integer:=16;
constant HADDR_WIDTH    : integer:=24;
constant SADDR_WIDTH    : natural := 13;
constant iterations     : integer:=400;

signal clk,rst,start : std_logic:='0';
signal local_data : std_logic_vector(15 downto 0);
type data_array is array(0 to iterations-1) of std_logic_vector(15 downto 0);
signal data_word : data_array; 
signal RdAddr        : std_logic_vector(HADDR_WIDTH-1 downto 0);
signal data_cnt      : unsigned(DATA_WIDTH-1 downto 0);
-- bus for holding output data from SDRAM
signal sData        : std_logic_vector(DATA_WIDTH-1 downto 0);
-- host side
signal rd           : std_logic;  -- initiate read operation
signal wr           : std_logic;  -- initiate write operation
signal earlyOpBegun : std_logic;  -- read/write/self-refresh op has begun (async)
signal opBegun      : std_logic;  -- read/write/self-refresh op has begun (clocked)
signal rdPending    : std_logic;  -- true if read operation(s) are still in the pipeline
signal done         : std_logic;  -- read or write operation is done
signal rdDone       : std_logic;  -- read operation is done and data is available
signal hAddr        : std_logic_vector(HADDR_WIDTH-1 downto 0);  -- address from host to SDRAM
signal hDIn         : std_logic_vector(DATA_WIDTH-1 downto 0);  -- data from host to SDRAM
signal hDOut        : std_logic_vector(DATA_WIDTH-1 downto 0);  -- data from SDRAM to host
signal status       : std_logic_vector(3 downto 0);
-- SDRAM side
signal cke          : std_logic;  -- clock-enable to SDRAM
signal ce_n         : std_logic;  -- chip-select to SDRAM
signal ras_n        : std_logic;  -- SDRAM row address strobe
signal cas_n        : std_logic;  -- SDRAM column address strobe
signal we_n         : std_logic;  -- SDRAM write enable
--signal ba           : std_logic_vector(1 downto 0);  -- SDRAM bank address
signal sAddr        : std_logic_vector(SADDR_WIDTH-1 downto 0);  -- SDRAM row/column address
signal sDIn         : std_logic_vector(DATA_WIDTH-1 downto 0);  -- data from SDRAM
signal sDOut        : std_logic_vector(DATA_WIDTH-1 downto 0);  -- data to SDRAM
signal sDOutEn      : std_logic;  -- true if data is output to SDRAM on sDOut
signal dqmh         : std_logic;  -- enable upper-byte of SDRAM databus if true
signal dqml         : std_logic;  -- enable lower-byte of SDRAM databus if true

signal we_rn    : std_logic;
signal AD       : std_logic_vector(31 downto 0);
signal data_addr_n : std_logic;
signal address  : std_logic_vector(31 downto 0);
signal data  : std_logic_vector(31 downto 0);
signal ba           : std_logic_vector(1 downto 0);
signal burst_terminate : std_logic;
signal row_active : std_logic;
signal cs_n : std_logic;
signal Clk_SDp: std_logic;
signal clk_sdram : std_logic;
-------------------------------------------------------------
-- Component declaration of the User Test
-------------------------------------------------------------
    component test
    end component;

begin
------------------------------------------------------------
-- Component Instatiation of the User Test
------------------------------------------------------------
    MAIN_TEST: test;
    
    clk<=NOT clk after (SYS_CLK_PERIOD/2);
    clk_sdram<=NOT clk after (SYS_CLK_PERIOD/2) when rst='0' else '0';
    --sData <= sDOut when sDOutEn = YES else (others => 'Z');
      
    main : process
        variable outline : LINE;
    begin
        rst<='1';
        wait for 101 ns;
        rst<='0';
        WRITE(outline,string'("Reset done ..."));WRITELINE(output,outline);
        wait until start='0';
        assert false report "End of the test" severity ERROR;
    end process main;   
    
    ops:process
        variable burst_length : integer;
        --variable random_uniform : uniform;
        procedure addr_wr(constant address : in std_logic_vector) is
        begin
            we_rn <='1';
            AD <= address;
            data_addr_n  <= '0';
            wait until rising_edge(clk);
        end;
        procedure data_wr(constant data : in std_logic_vector) is
        begin
            we_rn <='1';
            AD <= (others=>'0');
            AD <= data;
            data_addr_n  <= '1';
            wait until rising_edge(clk);
        end;
        procedure addr_rd(constant address : in std_logic_vector) is
        begin
            we_rn <='0';
            AD <= address;
            data_addr_n  <= '0';
            wait until rising_edge(clk);
        end;
        procedure data_rd is
        begin
            we_rn <='0';
            AD <= (others=>'Z');
            data_addr_n  <= '1';
            wait until rising_edge(clk);
        end;
        procedure nop is
        begin
            we_rn <='0';
            AD <= (others=>'Z');
            data_addr_n  <= '1';
            wait until rising_edge(clk);
        end;
        procedure ref is
        begin
            we_rn <='1';
            AD <= x"30000000";
            data_addr_n  <= '0';
            wait until rising_edge(clk);
        end;
    begin
        burst_terminate <= '0';
        row_active <= '0';
        burst_length := 0;
        start<='1';
        we_rn <= '1';
        data_addr_n <= '1';
        AD <= (others=>'Z');
        data_cnt <= (others=>'0');
        wait for 100 us;
        wait until rising_edge(clk);
        -- for a in 1 to 87 loop
            -- nop;
        -- end loop;
        addr_wr (x"20080000");
        -- C[1:0] 2 CAS latency    = 1
        -- C[3:2] 2 RAS to CAS delay  = 0
        -- C[6:4] 3 Burst length 1, 2, 4, 8 (0,1,3,7) = 7
        -- C[23:8] 16 Refresh count 2000-4000 = 1248
        -- C[27:24] 4 Refresh active period = 2
        data_wr (x"0204e074");  -- write page data_wr (x"0204e044");
        for a in 1 to 5 loop   
            nop;
        end loop;
        ref;
        for a in 1 to 5 loop   
            nop;
        end loop;
        ref;
        for a in 1 to 100 loop   
            nop;
        end loop;
        -- write page
        --addr_wr (x"10004E00");   -- loading MRS bits(19:9)
        addr_wr (x"10004600");   -- loading MRS bits(19:9)
        for a in 1 to 5 loop   
            nop;
        end loop;
        for c in 0 to 1000 loop
            --write data
            for a in 0 to 7 loop
                addr_wr (std_logic_vector(to_unsigned(a*8,32)));
                for b in 1 to 8 loop
                    data_wr (std_logic_vector(to_unsigned(a*8+b,32)));
                end loop;            
                AD <= (others=>'Z');
                nop;
                nop;
                nop;
                nop;
                row_active<='1';
            end loop;   
            for a in 0 to 7 loop
                addr_rd (std_logic_vector(to_unsigned(a*8,32)));
                data_rd;
                AD <= (others=>'Z');
                for b in 1 to 19 loop
                    nop;
                end loop;            
            end loop;  
        end loop;    
        nop;
        --wait for 1 us;
        start<='0';    
    end process;
    
    -- SDRAM memory controller module
    U_TEST : entity work.sdrm
    port map(
    -- System side
    AD          => AD,
    Reset       => rst,
	Clkp        => clk,
	Clk_FBp     => Clk_SDp,
	we_rn       => we_rn,
	data_addr_n	=> data_addr_n,
    burst_terminate  => burst_terminate,
    row_active  => row_active,
    -- SDRAM side
    sd_data => sData,     
	sd_add  => sAddr,
	sd_ras  => ras_n,
	sd_cas  => cas_n,
	sd_we   => we_n,
	sd_ba   => ba,
	Clk_SDp => Clk_SDp,
	sd_cke  => cke,
	sd_cs1  => cs_n, 
	sd_dqm(0) => dqml,
    sd_dqm(1) => dqmh
    );

      memory_model: entity work.mt48lc16m16a2
      port map(
        BA0     => ba(0),
        BA1     => ba(1),        
        DQMH    => dqmh,        
        DQML    => dqml,        
        DQ0     => sData(0),        
        DQ1     => sData(1),        
        DQ2     => sData(2),        
        DQ3     => sData(3),        
        DQ4     => sData(4),        
        DQ5     => sData(5),        
        DQ6     => sData(6),        
        DQ7     => sData(7),        
        DQ8     => sData(8),         
        DQ9     => sData(9),        
        DQ10    => sData(10),        
        DQ11    => sData(11),        
        DQ12    => sData(12),        
        DQ13    => sData(13),        
        DQ14    => sData(14),        
        DQ15    => sData(15),        
        CLK     => clk_sdram,        
        CKE     => cke,        
        A0      => sAddr(0),        
        A1      => sAddr(1),        
        A2      => sAddr(2),        
        A3      => sAddr(3),        
        A4      => sAddr(4),        
        A5      => sAddr(5),        
        A6      => sAddr(6),        
        A7      => sAddr(7),        
        A8      => sAddr(8),        
        A9      => sAddr(9),        
        A10     => sAddr(10),  
        A11     => sAddr(11),        
        A12     => sAddr(12),        
        WENeg   => we_n,       
        RASNeg  => ras_n,        
        CSNeg   => cs_n,        
        CASNeg  => cas_n        
      );
      
end architecture tb;
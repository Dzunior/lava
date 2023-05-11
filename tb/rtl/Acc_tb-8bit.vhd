-------------------------------------------------------------------------------
--
-- File         : Acc_tb.vhd
-- Author       : Dominik Domanski
-- Date         : 29/03/10
--
-- Last Check-in :
-- $Revision: 83 $
-- $Author: dzunior $
-- $Date: 2010-08-31 15:05:12 +0200 (mar, 31 ago 2010) $
--
-------------------------------------------------------------------------------
-- Description:
--
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_arith.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
library std;
use std.textio.all;
library Acc;
use Acc.common.all;
use Acc.AccTypes.all;
library acc_tb;
use Acc_tb.Acc_tb_pkg.all;
library GS_random;
use GS_random.rng2.all;

entity Acc_tb is
end Acc_tb;

architecture tb of Acc_tb is
    signal clk: std_logic:='0';
    signal sample_input: std_logic_vector (15 downto 0);
    signal sclk: std_logic:='0';
    signal sclk_en: std_logic:='1';
    signal wnr: std_logic;
    signal req: std_logic;
    signal arst: std_logic:='0';
    signal ack: std_logic;
    signal mosi: std_logic:='0';
    signal miso: std_logic:='0';
    signal ss_n: std_logic:='1';
    signal hsync_n: std_logic;
    signal vsync_n: std_logic;
    signal  hostctrl_full : std_logic;
    signal hostctrl_ack : std_logic;
    -- SDRAM side
    signal sData    : std_logic_vector(15 downto 0);
    signal cke      : std_logic;  -- clock-enable to SDRAM
    signal ce_n     : std_logic;  -- chip-select to SDRAM
    signal ras_n    : std_logic;  -- SDRAM row address strobe
    signal cas_n    : std_logic;  -- SDRAM column address strobe
    signal we_n     : std_logic;  -- SDRAM write enable
    signal ba       : std_logic_vector(1 downto 0);  -- SDRAM bank address
    signal sAddr    : std_logic_vector(12 downto 0);  -- SDRAM row/column address
    signal sDIn     : std_logic_vector(15 downto 0);  -- data from SDRAM
    signal sDOut    : std_logic_vector(15 downto 0);  -- data to SDRAM
    signal sDOutEn  : std_logic;  -- true if data is output to SDRAM on sDOut
    signal dqmh     : std_logic;  -- enable upper-byte of SDRAM databus if true
    signal dqml     : std_logic;  -- enable lower-byte of SDRAM databus if true
    signal display_rst      : std_logic;
    signal core_rst         : std_logic;
    signal dclk,lclk        : std_logic:='0';
    signal flash_ce_n	: std_logic;								-- CEn signal to left SRAM bank.
    signal flash_oe_n	: std_logic;								-- OEn signal to left SRAM bank.
    signal flash_we_n	: std_logic;								-- WEn signal to left SRAM bank.
    signal flash_rp_n  : std_logic;
    signal Addr : std_logic_vector (21 downto 0);	-- Address bus to left SRAM bank.
    signal Data : std_logic_vector (15 downto 0);	-- Data bus to left SRAM bank.
	  signal rxf_n,rst_n,rd_n,txe_n,wr,rstn : std_logic;
	  signal usb_data : std_logic_vector(7 downto 0);
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

    --lclk<=NOT lclk after (CORE_CLK_PERIOD/2);
    --dclk<=NOT dclk after (DISPLAY_CLK_PERIOD/2);
    clk<=NOT clk after 10 ns;
    --sclk<=NOT sclk after 20 ns when ss_n='0' else '0';
    --sData <= sDOut when sDOutEn = YES else (others => 'Z');
    
    main : process
        variable outline : LINE;
    begin
        arst<='0';
        display_rst <= '1';
        core_rst <= '1';
        wait for 100 ns;
        arst<='1';
        display_rst <= '0';
        core_rst <= '0';
        WRITE(outline,string'("Reset done ..."));WRITELINE(output,outline);
        start<='1';
        wait until falling_edge(arst);
    end process main;

    process

    begin
        wait until rising_edge(clk);
        if regH.initWr='1' then
            if hostctrl_full='0' then
                regH.accept<='0';
                rxf_n <= '0';
                wait until falling_edge(rd_n);
                wait for 30 ns;
                usb_data <= regH.Wrdata(15 downto 8);
                wait until rising_edge(rd_n);
                rxf_n <= '1';
                wait for 80 ns;
                rxf_n <= '0';
                wait until falling_edge(rd_n);
                wait for 30 ns;
                usb_data <= regH.Wrdata(7 downto 0);
                wait until rising_edge(rd_n);
                rxf_n <= '1';
                wait for 80 ns;
                wait until rising_edge(lclk);
                regH.accept<='1';
            end if; 
       -- elsif regH.initRd='1' then
           -- wait until hostctrl_ack='1';
            -- wait for SCLK_PERIOD*10;
            -- regH.accept<='0';
            -- regH.Rddata <= (others=>'Z');
            -- ss_n <= '0';
            -- for i in 15 downto 0 loop
                -- wait until rising_edge(sclk);
                -- regH.Rddata(i)<= miso;
            -- end loop;
            -- ss_n <= '1';
            -- wait until rising_edge(lclk);   
            -- regH.accept<='1';
            -- wait until rising_edge(lclk);   
        end if;
    end process;

    U_TEST:entity Acc.Accelerator
    port map (
        rst_n           => arst,
        clk             => clk,
        lclk            => lclk,
        -- host side
		rstn            => rstn,   
		rxf_n			=> rxf_n,	
		rd_n			=> rd_n,	
		usb_data    	=> usb_data,	
		txe_n			=> txe_n,	
		wr				=> wr,	
        hostctrl_full   => hostctrl_full,
		-- Display
        r               => open,
        g               => open,
        b               => open,
        hsync_n         => hsync_n,
        vsync_n         => vsync_n,
        cke             => cke,
        ce_n            => ce_n,
        ras_n           => ras_n,
        cas_n           => cas_n,
        we_n            => we_n,
        ba              => ba,
        Addr            => Addr,
        Data            => Data,
        dqmh            => dqmh,
        dqml            => dqml,
        flash_ce_n      => flash_ce_n,
        flash_oe_n      => flash_oe_n,  
        flash_we_n      => flash_we_n,
        flash_rp_n      => flash_rp_n
        );

    SDRAM_model: entity work.mt48lc16m16a2
      port map(
        BA0     => ba(0),
        BA1     => ba(1),
        DQMH    => dqmh,
        DQML    => dqml,
        DQ0     => Data(0),
        DQ1     => Data(1),
        DQ2     => Data(2),
        DQ3     => Data(3),
        DQ4     => Data(4),
        DQ5     => Data(5),
        DQ6     => Data(6),
        DQ7     => Data(7),
        DQ8     => Data(8),
        DQ9     => Data(9),
        DQ10    => Data(10),
        DQ11    => Data(11),
        DQ12    => Data(12),
        DQ13    => Data(13),
        DQ14    => Data(14),
        DQ15    => Data(15),
        CLK     => lclk,
        CKE     => cke,
        A0      => Addr(0),
        A1      => Addr(1),
        A2      => Addr(2),
        A3      => Addr(3),
        A4      => Addr(4),
        A5      => Addr(5),
        A6      => Addr(6),
        A7      => Addr(7),
        A8      => Addr(8),
        A9      => Addr(9),
        A10     => Addr(10),
        A11     => Addr(11),
        A12     => Addr(12),
        WENeg   => we_n,
        RASNeg  => ras_n,
        CSNeg   => ce_n,
        CASNeg  => cas_n
    );

    FLASH_model : entity work.m28w320cb
    port map(
        A20     => Addr(20),        
        A19     => Addr(19),       
        A18     => Addr(18),       
        A17     => Addr(17),       
        A16     => Addr(16),            
        A15     => Addr(15),            
        A14     => Addr(14),       
        A13     => Addr(13),            
        A12     => Addr(12),            
        A11     => Addr(11),       
        A10     => Addr(10),            
        A9      => Addr(9),           
        A8      => Addr(8),       
        A7      => Addr(7),           
        A6      => Addr(6),            
        A5      => Addr(5),       
        A4      => Addr(4),            
        A3      => Addr(3),            
        A2      => Addr(2),       
        A1      => Addr(1),            
        A0      => Addr(0),            
        D15     => Data(15),       
        D14     => Data(14),       
        D13     => Data(13),       
        D12     => Data(12),       
        D11     => Data(11),       
        D10     => Data(10),       
        D9      => Data(9),        
        D8      => Data(8),        
        D7      => Data(7),        
        D6      => Data(6),        
        D5      => Data(5),        
        D4      => Data(4),        
        D3      => Data(3),        
        D2      => Data(2),        
        D1      => Data(1),        
        D0      => Data(0),        
        CENeg   => flash_ce_n,
        OENeg   => flash_oe_n,       
        WENeg   => flash_we_n,       
        RPNeg   => flash_rp_n,      
        WPNeg   => '1',       
        VPP     => '1'
    );          
    
    -- U_GEN:entity A =>cc.gen
    -- port map(     =>
        -- clk             =>=> clk,
        -- rst             =>=> arst,
        -- host_data =>      => host_data,
        -- host_data_valid => host_data_valid
    -- );

end architecture tb;
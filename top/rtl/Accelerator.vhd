-------------------------------------------------------------------------------
--
-- File         : Accelerator.vhd
-- Author       : Dominik Domanski
-- Date         : 27/03/10
--
-- Last Check-in :
-- $Revision: 144 $
-- $Author: dzunior $
-- $Date: 2010-11-09 20:02:53 +0100 (mar, 09 nov 2010) $
--
-------------------------------------------------------------------------------
-- Description:
-- Top module
-------------------------------------------------------------------------------
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library work;
use work.AccTypes.all;

entity Accelerator is
    port (
        clk     : in std_logic;
        --rst     : in std_logic;
        lclk    : out std_logic;
        -- Host interface
        strobe_n: in std_logic;
        rnw_n   : in std_logic;
        host_data: inout std_logic_vector(7 downto 0);
        op_done : out std_logic;
        -- Display interface
        r,b     : out std_logic_vector(NUM_RGB_BITS-1 downto 0);
        g       : out std_logic_vector(NUM_RGB_BITS downto 0);
        hsync_n : out std_logic;
        vsync_n : out std_logic;
        blank   : out std_logic; -- signal used by RGB DACs
        -- SDRAM memory interface
        cke     : out std_logic;            -- clock-enable to SDRAM
        ce_n    : out std_logic;            -- chip-select to SDRAM
        ras_n   : out std_logic;            -- SDRAM row address strobe
        cas_n   : out std_logic;            -- SDRAM column address strobe
        we_n    : out std_logic;            -- SDRAM write enable
        ba      : out std_logic_vector(1 downto 0);  -- SDRAM bank address
        Addr    : out std_logic_vector(FLASH_ADDR_WIDTH-1 downto 0);  -- SDRAM row/column address
        Data    : inout  std_logic_vector(MEM_DATA_WIDTH-1 downto 0);  -- data  to/from SDRAM
        dqmh    : out std_logic;            -- enable upper-byte of SDRAM databus if true
        dqml    : out std_logic;            -- enable lower-byte of SDRAM databus if true
        -- Flash memory interface
        flash_ce_n: out std_logic;            -- CEn signal to left SRAM bank.
        flash_oe_n: out std_logic;            -- OEn signal to left SRAM bank.
        flash_we_n: out std_logic;            -- WEn signal to left SRAM bank.
        flash_wp_n : out std_logic;
        flash_rp_n: out std_logic
        );
end entity Accelerator;

architecture rtl of Accelerator is
    -- HostCtrl
    signal hostctrl_data    : std_logic_vector(HOST_BUS_WIDTH-1 downto 0);
    signal hostctrl_rdreq   : std_logic;
    signal hostctrl_empty   : std_logic;
    signal read_ack         : std_logic;
    signal read_data        : std_logic_vector(HOST_BUS_WIDTH-1 downto 0);
    signal read_done        : std_logic;
    -- DisplayCtrl
    signal vsync_cnt        : std_logic_vector(Y_RES_SIZE-1 downto 0);
    signal core_rst_n       : std_logic;
    signal core_rst         : std_logic;
    signal lclk_int         : std_logic;
    signal rd_mem           : std_logic;
    signal wr_mem           : std_logic;
    signal earlyOpBegun     : std_logic;
    signal opBegun          : std_logic;
    signal rdPending        : std_logic;
    signal rdDone,done      : std_logic;
    signal hAddr            : std_logic_vector (HADDR_WIDTH-1 downto 0);
    signal data_rd          : std_logic_vector (MEM_DATA_WIDTH-1 downto 0);
    signal status           : std_logic_vector (3 downto 0);
    signal data_wr          : std_logic_vector (MEM_DATA_WIDTH-1 downto 0);
    signal wr_display       : std_logic;
    signal pixel_data       : std_logic_vector (15 downto 0);
    signal eof              : std_logic;
    signal lock             : std_logic;
    signal hsync_n_int      : std_logic;
    signal vsync_n_int      : std_logic;
    signal sDOut            : std_logic_vector(MEM_DATA_WIDTH-1 downto 0);
    signal sDOutEn          : std_logic;
    signal sAddr            : std_logic_vector(SADDR_WIDTH-1 downto 0);
     --signal r_int,b_int        : std_logic_vector(4 downto 0);
     --signal g_int              : std_logic_vector(5 downto 0);
    -- FlashCtrl
    signal flash_rdreq      : std_logic;
    signal flash_wreq       : std_logic;
    signal flash_rwaddr     : std_logic_vector (FLASH_ADDR_WIDTH-1 downto 0);
    signal flash_rdata      : std_logic_vector (FLASH_BUS_WIDTH-1 downto 0);
    signal flash_wdata      : std_logic_vector (FLASH_BUS_WIDTH-1 downto 0);
    signal flash_op_valid   : std_logic;
    signal flash_ce_n_int   : std_logic;
    signal flash_addr       : std_logic_vector (FLASH_ADDR_WIDTH-1 downto 0);   
    signal flash_w_data     : std_logic_vector (FLASH_BUS_WIDTH-1 downto 0);
    signal flash_r_data     : std_logic_vector (FLASH_BUS_WIDTH-1 downto 0);
    signal flash_oe_n_int   : std_logic;
    signal flash_we_n_int   : std_logic;
    signal flash_srst       : std_logic;
    signal display_full     : std_logic;
    signal srst             : std_logic;
    signal data_out         : std_logic_vector(7 downto 0);
    signal data_en          : std_logic;

begin

    flash_wp_n <= '1';
    lclk <= not lclk_int;
    lock <= core_rst_n;
    --hostctrl_ack <= read_ack;
    flash_ce_n <= flash_ce_n_int;
    flash_oe_n <= flash_oe_n_int;
    flash_we_n <= flash_we_n_int;
    Data <= sDout when sDOutEn ='1' else flash_w_data when flash_ce_n_int='0' and flash_oe_n_int='1' else (others => 'Z');
    Addr <= flash_addr when flash_ce_n_int='0' else b"0"&x"00"&sAddr;
    flash_r_data <= Data;
    core_rst <= '0';--not(core_rst_n);
    host_data <= data_out when data_en='1' else (others => 'Z');

    U_HostCtrl:entity work.HostCtrl
    port map(
        rst             => srst,
        clk             => lclk_int,
        -- host interface
        strobe_n        => strobe_n,
        rnw_n           => rnw_n,
        data_out        => data_out,
        data_in         => host_data,
        data_en         => data_en,
        done            => op_done,
        -- accelerator side
        hostctrl_data   => hostctrl_data,
        hostctrl_rdreq  => hostctrl_rdreq,
        hostctrl_empty  => hostctrl_empty,  
        read_data       => read_data,
        read_ack        => read_ack,
        read_done       => read_done
        );

    U_2dEngine:entity work.Engine
    port map(
        rst             => srst,
        clk             => lclk_int,
        -- MemCtrl interface
        rd_mem          => rd_mem,
        wr_mem          => wr_mem,
        earlyOpBegun    => earlyOpBegun,
        done            => done,
        hAddr           => hAddr,
        data_wr         => data_wr,
        data_rd         => data_rd,
        status          => status,
        -- HostCtrl interface
        hostctrl_data   => hostctrl_data,
        hostctrl_rdreq  => hostctrl_rdreq,
        hostctrl_empty  => hostctrl_empty,
        read_data       => read_data,
        read_ack        => read_ack,
        read_done       => read_done,
        -- DisplayCtrl interface
        wr_display      => wr_display,
        pixel_data      => pixel_data,
        eof             => eof,
        hsync_n         => hsync_n_int,
        vsync_cnt       => vsync_cnt,
        -- FlashCtrl interface
        flash_rdreq     => flash_rdreq,
        flash_wreq      => flash_wreq,
        flash_rwaddr    => flash_rwaddr,
        flash_rdata     => flash_rdata,
        flash_wdata     => flash_wdata,
        flash_op_valid  => flash_op_valid,
        flash_srst      => flash_srst
        );

    U_MemCtrl:entity work.MemCtrl
    generic map(
        FREQ        => CLK_FREQ,
        MULTIPLE_ACTIVE_ROWS => FALSE,
        PIPE_EN         => TRUE
        )
    port map(
        -- host side
        clk          => lclk_int,
        lock         => lock,
        rst          => srst,
        rd           => rd_mem,
        wr           => wr_mem,
        earlyOpBegun => earlyOpBegun,
        opBegun      => opBegun,
        rdPending    => rdPending,
        done         => done,
        rdDone       => rdDone,
        hAddr        => hAddr,
        hDIn         => data_wr,
        hDout        => data_rd,
        status       => status,
        -- SDRAM side
        cke          => cke,
        ce_n         => ce_n,
        ras_n        => ras_n,
        cas_n        => cas_n,
        we_n         => we_n,
        ba           => ba,
        sAddr        => sAddr,
        sDIn         => Data,
        sDOut        => sDOut,
        sDOutEn      => sDOutEn,
        dqmh         => dqmh,
        dqml         => dqml
        );

    U_DisplayCtrl:entity work.DisplayCtrl
    generic map (
        FREQ            => CLK_FREQ,
        CLK_DIV         => CLK_FREQ/40000,
        PIXEL_WIDTH     => PIXEL_WIDTH,
        PIXELS_PER_LINE => X_RESOLUTION,  --PIXELS_PER_LINE,
        LINES_PER_FRAME => Y_RESOLUTION,  --LINES_PER_FRAME,
        NUM_RGB_BITS    => NUM_RGB_BITS,  -- wNUM_RGB_BITS,
        FIT_TO_SCREEN   => false --  use default parameters for 800x600 60Hz
        )
    port map (
        rst             => srst,
        clk             => lclk_int,         -- use the resync'ed master clock so VGA generator is in sync with SDRAM
        wr              => wr_display,        -- write to pixel buffer when the data read from SDRAM is available
        pixel_data_in   => pixel_data,  -- pixel data from SDRAM
        eof             => eof,           -- indicates when the VGA generator has finished a video frame
        r               => r,           -- RGB components
        g               => g,
        b               => b,
        hsync_n         => hsync_n_int,       -- horizontal sync
        vsync_n         => vsync_n_int,       -- vertical sync
        blank           => blank,
        vsync_cnt       => vsync_cnt,
        full            => display_full
        );

    U_FlashCtrl: entity work.FlashCtrl
    generic map(
        FREQ            => CLK_FREQ
        )
    port map(
        clk             => lclk_int,
        rst             => srst,
        --User side
        flash_rdreq     => flash_rdreq,
        flash_wreq      => flash_wreq,
        flash_rwaddr    => flash_rwaddr,
        flash_rdata     => flash_rdata,
        flash_wdata     => flash_wdata,
        flash_op_valid  => flash_op_valid,
        --Flash memory side
        flash_ce_n      => flash_ce_n_int,
        flash_oe_n      => flash_oe_n_int,
        flash_we_n      => flash_we_n_int,
        addr            => flash_addr,
        w_data          => flash_w_data,
        r_data          => flash_r_data,
        flash_rp_n      => flash_rp_n,
        flash_srst      => flash_srst
    );

    U_DCM_Core: entity work.dcm_core
    port map(
        CLKIN_IN          => clk,
        --RST_IN            => rst,
        CLKFX_OUT         => lclk_int,
        CLKIN_IBUFG_OUT   => open,
        CLK0_OUT          => open,
        LOCKED_OUT        => core_rst_n
        );

    U_Reset : entity work.Reset
    port map(
            arst    => core_rst,
            clk     => lclk_int,
            rst     => srst
            );

hsync_n <= hsync_n_int;
vsync_n <= vsync_n_int;

end architecture rtl;

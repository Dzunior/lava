--------------------------------------------------------------------------------
-- Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    Vendor: Xilinx 
-- \   \   \/     Version : 10.1.03
--  \   \         Application : xaw2vhdl
--  /   /         Filename : ClkDiv.vhd
-- /___/   /\     Timestamp : 04/06/2010 15:35:10
-- \   \  /  \ 
--  \___\/\___\ 
--
--Command: xaw2vhdl-st D:\addsvn_accelerator\ClkDiv.xaw D:\addsvn_accelerator\ClkDiv
--Design Name: ClkDiv
--Device: xc3s500e-4fg320
--
-- Module ClkDiv
-- Generated by Xilinx Architecture Wizard
-- Written for synthesis tool: XST
-- Period Jitter (unit interval) for block DCM_SP_INST = 0.04 UI
-- Period Jitter (Peak-to-Peak) for block DCM_SP_INST = 0.92 ns

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;

entity ClkDiv is
    generic(
        CLKDV_DIVIDE    : real:= 2.0;
        CLKFX_DIVIDE    : natural:= 5;
        CLKFX_MULTIPLY  : natural:=4;
        CLKIN_PERIOD    : real:=20.000
        );
   port ( CLKIN_IN        : in    std_logic; 
          RST_IN          : in    std_logic; 
          CLKFX_OUT       : out   std_logic; 
          CLKFX180_OUT    : out   std_logic; 
          CLKIN_IBUFG_OUT : out   std_logic; 
          CLK0_OUT        : out   std_logic; 
          CLK2X_OUT       : out   std_logic; 
          LOCKED_OUT      : out   std_logic);
end ClkDiv;

architecture BEHAVIORAL of ClkDiv is
   signal CLKFB_IN        : std_logic;
   signal CLKFX_BUF       : std_logic;
   signal CLKFX180_BUF    : std_logic;
   signal CLKIN_IBUFG     : std_logic;
   signal CLK0_BUF        : std_logic;
   signal CLK2X_BUF       : std_logic;
   signal GND_BIT         : std_logic;
begin
   GND_BIT <= '0';
   CLKIN_IBUFG_OUT <= CLKIN_IBUFG;
   CLK0_OUT <= CLKFB_IN;
   CLKFX_BUFG_INST : BUFG
      port map (I=>CLKFX_BUF,
                O=>CLKFX_OUT);
   
   CLKFX180_BUFG_INST : BUFG
      port map (I=>CLKFX180_BUF,
                O=>CLKFX180_OUT);
   
   CLKIN_IBUFG_INST : IBUFG
      port map (I=>CLKIN_IN,
                O=>CLKIN_IBUFG);
   
   CLK0_BUFG_INST : BUFG
      port map (I=>CLK0_BUF,
                O=>CLKFB_IN);
   
   CLK2X_BUFG_INST : BUFG
      port map (I=>CLK2X_BUF,
                O=>CLK2X_OUT);
   
   DCM_SP_INST : DCM_SP
   generic map( CLK_FEEDBACK => "1X",
            CLKDV_DIVIDE => CLKDV_DIVIDE,
            CLKFX_DIVIDE => CLKFX_DIVIDE,
            CLKFX_MULTIPLY => CLKFX_MULTIPLY,
            CLKIN_DIVIDE_BY_2 => FALSE,
            CLKIN_PERIOD => CLKIN_PERIOD,
            CLKOUT_PHASE_SHIFT => "NONE",
            DESKEW_ADJUST => "SYSTEM_SYNCHRONOUS",
            DFS_FREQUENCY_MODE => "LOW",
            DLL_FREQUENCY_MODE => "LOW",
            DUTY_CYCLE_CORRECTION => TRUE,
            FACTORY_JF => x"C080",
            PHASE_SHIFT => 0,
            STARTUP_WAIT => FALSE)
      port map (CLKFB=>CLKFB_IN,
                CLKIN=>CLKIN_IBUFG,
                DSSEN=>GND_BIT,
                PSCLK=>GND_BIT,
                PSEN=>GND_BIT,
                PSINCDEC=>GND_BIT,
                RST=>RST_IN,
                CLKDV=>open,
                CLKFX=>CLKFX_BUF,
                CLKFX180=>CLKFX180_BUF,
                CLK0=>CLK0_BUF,
                CLK2X=>CLK2X_BUF,
                CLK2X180=>open,
                CLK90=>open,
                CLK180=>open,
                CLK270=>open,
                LOCKED=>LOCKED_OUT,
                PSDONE=>open,
                STATUS=>open);
   
end BEHAVIORAL;


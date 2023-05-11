-------------------------------------------------------------------------------
--
-- File         : HostCtrl.vhd
-- Author       : Dominik Domanski
-- Date         : 19/09/10
--
-- Last Check-in :
-- $Revision: 140 $
-- $Author: dzunior $
-- $Date: 2010-11-09 19:48:56 +0100 (mar, 09 nov 2010) $
--
-------------------------------------------------------------------------------
-- Description:
-- uC parallel communciation
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.AccTypes.all;
use work.common.all;

entity HostCtrl is
    port (
        rst             : in std_logic;   -- reset
        clk             : in  std_logic;  -- system clock
        -- parallel interface
        strobe_n        : in std_logic;
        rnw_n           : in std_logic;
        data_out        : out std_logic_vector(7 downto 0);
        data_in         : in std_logic_vector(7 downto 0);
        data_en         : out std_logic;
        done           : out std_logic;
        -- 2D Engine interface
        hostctrl_data   : out std_logic_vector (HOST_BUS_WIDTH-1 downto 0);
        hostctrl_rdreq  : in std_logic;
        hostctrl_empty  : out std_logic;
        read_data       : in std_logic_vector (HOST_BUS_WIDTH-1 downto 0);
        read_ack        : in std_logic;
        read_done       : out std_logic
        );
end entity HostCtrl;

architecture rtl of HostCtrl is

type StateType is (IDLE,READ_WAIT,WRITE_WAIT);
signal state : StateType;
signal hostctrl_wreq : std_logic;
signal hostctrl_full : std_logic;
signal byte : std_logic;
signal data_in_int : std_logic_vector(7 downto 0);
signal read_done_int : std_logic;
signal strobe_n_int,strobe_n_in_0,strobe_n_schmitt : std_logic;
signal rnw_n_int,rnw_n_int_0,rnw_n_int_schmitt : std_logic;

component host_fifo
    port (
    din: in std_logic_vector(7 downto 0);
    rd_clk: in std_logic;
    rd_en: in std_logic;
    rst: in std_logic;
    wr_clk: in std_logic;
    wr_en: in std_logic;
    dout: out std_logic_vector(HOST_BUS_WIDTH-1 downto 0);
    empty: out std_logic;
    full: out std_logic;
    prog_full : out std_logic);
end component;

attribute box_type : string;
attribute box_type of host_fifo : component is "black_box";

begin

read_done <= read_done_int;

U_host_fifo : host_fifo
    port map (
        din => data_in_int,
        rd_clk => clk,
        rd_en => hostctrl_rdreq,
        rst => rst,
        wr_clk => clk,
        wr_en => hostctrl_wreq,
        dout => hostctrl_data,
        empty => hostctrl_empty,
        full => open,
        prog_full => hostctrl_full
        );

U_host:process(clk,rst)
    begin
        if rst='1' then
            state <= IDLE;
            done <= '1';
            data_en <= '0';
            hostctrl_wreq <= '0';
            byte <= '0';
            data_out <= (others=>'0');
            read_done_int <= '0';
            data_in_int <= (others=>'0');
            strobe_n_in_0 <= '1';
            strobe_n_int <= '1';
            strobe_n_schmitt <= '1';
            rnw_n_int_0 <= '0';
            rnw_n_int <= '0';
            rnw_n_int_schmitt <= '0';
        elsif rising_edge(clk) then
            data_in_int <= data_in;
            strobe_n_in_0 <= strobe_n;
            strobe_n_int <= strobe_n_in_0;
            strobe_n_schmitt <= strobe_n_int;
            rnw_n_int_0 <= rnw_n;
            rnw_n_int <= rnw_n_int_0;
            rnw_n_int_schmitt <= rnw_n_int;
            if read_ack='1' then
                read_done_int <= '0';
            end if;
            state <= IDLE;
            hostctrl_wreq <= '0';
            data_en <= '0';
            done <= '0';
            if byte='0' then
                data_out <= read_data(15 downto 8);
            else
                data_out <= read_data(7 downto 0);
            end if; 
            case state is
                when IDLE =>
                    if strobe_n_int='0' and strobe_n_schmitt='0' then
                        if rnw_n_int='0' and rnw_n_int_schmitt='0' then 
                            if hostctrl_full='0' then
                                hostctrl_wreq <= '1';
                                done <= '1';
                                state <= WRITE_WAIT;
                            else
                                hostctrl_wreq <= '0';
                                done <= '0';
                                state <= IDLE;
                            end if;    
                        elsif rnw_n_int='1' and rnw_n_int_schmitt='1' then
                            if read_ack='1' then
                                state <= READ_WAIT;
                                data_en <= '1';
                                done <= '1';
                            else
                                state <= IDLE;
                                done <= '0';
                                data_en <= '0';
                            end if;
                        else
                            state <= IDLE;
                        end if;    
                    else
                        state <= IDLE;
                    end if; 
                when WRITE_WAIT =>
                    if strobe_n_int='1' and strobe_n_schmitt='1' then
                        state <= IDLE;
                        done <= '0';
                    else
                        done <= '1';
                        state <= WRITE_WAIT;
                    end if;
                when READ_WAIT =>
                    data_en <= '1';
                    if strobe_n_int='1' and strobe_n_schmitt='1' then
                        byte <= not byte;
                        done <= '0';
                        state <= IDLE;
                        if byte='1' then
                            read_done_int <= '1';
                        else
                            read_done_int <= '0';
                        end if;
                    else
                        done <= '1';
                        state <= READ_WAIT;
                    end if;
                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;

end architecture rtl;

-------------------------------------------------------------------------------
--
-- File         : Engine.vhd
-- Author       : Dominik Domanski
-- Date         : 27/03/10
--
-- Last Check-in :
-- $Revision: 145 $
-- $Author: dzunior $
-- $Date: 2010-11-11 17:07:40 +0100 (jue, 11 nov 2010) $
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

entity Engine is
    port (
        rst             : in  std_logic;  -- reset
        clk             : in  std_logic;  -- system clock
        -- MemCtrl interface
        rd_mem         : out  std_logic;  -- initiate read operation
        wr_mem         : out std_logic;  -- initiate write operation
        earlyOpBegun   : in std_logic;  -- read/write/self-refresh op has begun (async)
        done           : in std_logic;  -- read or write operation is done
        hAddr          : out  std_logic_vector(HADDR_WIDTH-1 downto 0); -- address from host to SDRAM
        data_wr        : out  std_logic_vector(MEM_DATA_WIDTH-1 downto 0);  -- data from host  to SDRAM
        data_rd        : in std_logic_vector(MEM_DATA_WIDTH-1 downto 0);  -- data from SDRAM to host
        status         : in std_logic_vector(3 downto 0);  -- diagnostic status of the FSM
        -- HostCtrl interface
        hostctrl_data   : in std_logic_vector (HOST_BUS_WIDTH-1 downto 0);
        hostctrl_rdreq  : out std_logic;
        hostctrl_empty  : in std_logic;
        read_data       : out std_logic_vector (HOST_BUS_WIDTH-1 downto 0);
        read_ack        : out std_logic;
        read_done       : in std_logic;
        -- DisplayCtrl interface
        wr_display      : out  std_logic;    -- write-enable for pixel buffer
        pixel_data      : out  std_logic_vector(MEM_DATA_WIDTH-1 downto 0);  -- input databus to pixel buffer
        eof             : in std_logic;    -- end of vga frame
        hsync_n         : in std_logic;    -- horizontal sync pulse
        vsync_cnt       : in std_logic_vector(Y_RES_SIZE-1 downto 0);    -- vertical sync pulse
        -- FlashCtrl interface
        flash_rdreq     : out std_logic;
        flash_wreq      : out std_logic;
        flash_rwaddr    : out std_logic_vector (FLASH_ADDR_WIDTH-1 downto 0);
        flash_rdata     : in std_logic_vector (FLASH_BUS_WIDTH-1 downto 0);
        flash_wdata     : out std_logic_vector (FLASH_BUS_WIDTH-1 downto 0);
        flash_op_valid  : in std_logic;
        flash_srst      : out std_logic
);
end entity Engine;

architecture rtl of Engine is
-- types
type StateType is  (PWR_UP,CLEAR_MEM,REFRESH_DISPLAY,IDLE,WRITE_DRAW,WRITE_MEM_BLOCK,READ_MEM_BLOCK,RW_MEMORY,WAIT_STATE);
type OpStateType is (PWR_UP,IDLE,PARAMETERS_0,PARAMETERS_1,MEM_COPY_OP,READ_MEMORY_REGISTER,WRITE_MEMORY_REGISTER,DRAW_TEXT_0,DRAW_TEXT_1,DRAW_TEXT_2);
-- signals
signal state            : StateType;
signal return_rnw_state : StateType;
signal op_state         : OpStateType;
signal draw_data_in     : std_logic_vector(DrawDataRange);
signal hsync_n_prev     : std_logic;
signal parameter        : ParametersArray;
signal cnt              : unsigned(X_RES_SIZE-1 downto 0);
signal hsync_flag       : std_logic;
signal mem_ready        : std_logic;
signal rw_memory_flag   : std_logic;
signal read_cnt         : unsigned(X_RES_SIZE-1 downto 0);
signal write_cnt        : unsigned(X_RES_SIZE-1 downto 0);
signal done_cnt         : unsigned(X_RES_SIZE-1 downto 0);
signal addr             : unsigned(HADDR_WIDTH-1 downto 0);
signal display_buffer_id: std_logic;
signal next_display_buffer_id : std_logic;
signal draw_buffer_id   : std_logic;
signal rnw_flag         : std_logic;
signal rnw_csr          : std_logic;
signal csr_flag         : std_logic;
signal color            : std_logic_vector(MEM_DATA_WIDTH-1 downto 0);
signal transparency_color:std_logic_vector(MEM_DATA_WIDTH-1 downto 0);
signal font_x           : std_logic_vector(X_RES_SIZE-1 downto 0);
signal font_y           : std_logic_vector(Y_RES_SIZE-1 downto 0);
signal src_mem_type     : std_logic;
signal op_ack           : std_logic;
signal op_busy          : std_logic;
signal data_wr_int      : std_logic_vector(MEM_DATA_WIDTH-1 downto 0);
signal display_ready    : std_logic;
signal refresh_flag     : std_logic;
signal block_length  	: unsigned(9 downto 0);
-- draw fifo signals
signal draw_fifo_full   : std_logic;
signal draw_fifo_empty  : std_logic;
signal draw_addr        : std_logic_vector(Y_RES_SIZE+X_RES_SIZE-1 downto 0);
signal draw_data_out    : std_logic_vector(MEM_DATA_WIDTH-1 downto 0);
signal draw_wreq        : std_logic;
signal draw_rdreq       : std_logic;
signal draw_data_count  : unsigned(9 downto 0);
-- block fifo signals
signal block_fifo_full  : std_logic;
signal block_fifo_empty : std_logic;
signal block_data_count : unsigned(10 downto 0);
signal block_fifo_in    : std_logic_vector(MEM_DATA_WIDTH-1 downto 0);
signal block_fifo_out   : std_logic_vector(MEM_DATA_WIDTH-1 downto 0);
signal block_fifo_wreq  : std_logic;
signal block_fifo_rdreq : std_logic;
-- font ram signals
signal font_rom_addr    : std_logic_vector(10 downto 0);
signal font_rom_out     : std_logic_vector(7 downto 0);
------------------------------------------------------------------------
signal transfer_cnt     : ParametersArrayRange;
signal transfer_limit   : ParametersArrayRange;
signal command          : OpStateType;
-- draw line calculation signals
signal x                : unsigned(X_RES_SIZE-1 downto 0);
signal y                : unsigned(Y_RES_SIZE-1 downto 0);
-- draw text signals
signal bit_position     : unsigned(2 downto 0);
signal char_line        : unsigned(3 downto 0);
signal letter_no        : unsigned(3 downto 0);
-- aliases
alias object_name   is parameter(4);
alias addr_x        is addr(XpixelRange);
alias addr_y        is addr(YpixelRange);
alias csr_addr      :unsigned(3 downto 0) is parameter(1)(3 downto 0);

component draw_fifo
    port (
        clk     : IN std_logic;
        srst    : IN std_logic;
        din     : IN std_logic_VECTOR(35 downto 0);
        wr_en   : IN std_logic;
        rd_en   : IN std_logic;
        dout    : OUT std_logic_VECTOR(35 downto 0);
        full    : OUT std_logic;
        empty   : OUT std_logic);
end component;

component block_fifo
    port (
        clk     : IN std_logic;
        din     : IN std_logic_VECTOR(15 downto 0);
        rd_en   : IN std_logic;
        srst    : IN std_logic;
        wr_en   : IN std_logic;
        dout    : OUT std_logic_VECTOR(15 downto 0);
        empty   : OUT std_logic;
        full    : OUT std_logic);
end component;

component font_rom
    port (
    clka    : in std_logic;
    addra   : in std_logic_vector(10 downto 0);
    douta   : out std_logic_vector(7 downto 0));
end component;

attribute box_type : string;
attribute box_type of draw_fifo : component is "black_box";
attribute box_type of block_fifo : component is "black_box";
attribute box_type of font_rom: component is "black_box";

begin

U_draw_fifo : entity work.draw_fifo
    port map (
        din                             => draw_data_in,
        clk                             => clk,
        rd_en                           => draw_rdreq,
        srst                            => rst,
        wr_en                           => draw_wreq,
        dout(DrawAddrRange)             => draw_addr,
        dout(MEM_DATA_WIDTH-1 downto 0) => draw_data_out,
        empty                           => draw_fifo_empty,
        full                            => draw_fifo_full
        );

U_block_fifo : entity work.block_fifo
    port map (
        clk          => clk,
        din          => block_fifo_in,
        rd_en        => block_fifo_rdreq,
        srst         => rst,
        wr_en        => block_fifo_wreq,
        dout         => block_fifo_out,
        empty        => block_fifo_empty,
        full         => block_fifo_full
        );

U_font_rom : entity work.font_rom
    port map (
        clka    => clk,
        addra   => font_rom_addr,
        douta   => font_rom_out
        );

data_wr <= block_fifo_out when state=WRITE_MEM_BLOCK else data_wr_int;
block_fifo_rdreq <= earlyOpBegun when state=WRITE_MEM_BLOCK else '0';
hAddr <= std_logic_vector(addr);

U_fifo_datacount : process(clk)
        variable draw_fifo_mode : std_logic_vector(1 downto 0);
        variable block_fifo_mode: std_logic_vector(1 downto 0);
    begin
        if rising_edge(clk) then
            if rst='1' then
                draw_data_count <= (others=>'0');
                block_data_count <= (others=>'0');
            else
                draw_fifo_mode := draw_wreq&draw_rdreq;
                case draw_fifo_mode is
                    when b"01" =>
                        draw_data_count <= draw_data_count-1;
                    when b"10" =>
                        draw_data_count <= draw_data_count+1;
                    when others =>
                        null;
                end case;
                block_fifo_mode := block_fifo_wreq&block_fifo_rdreq;
                case block_fifo_mode is
                    when b"01" =>
                        block_data_count <= block_data_count-1;
                    when b"10" =>
                        block_data_count <= block_data_count+1;
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;

    SM_mem_operations:process(rst,clk)
        procedure Reset is
        begin
            rd_mem          <= '0';
            wr_mem          <= '0';
            draw_rdreq      <= '0';
            block_fifo_wreq <= '0';
            wr_display      <= '0';
            flash_rdreq     <= '0';
            flash_wreq      <= '0';
            flash_srst      <= '0';
        end;
        procedure RefreshInterrupt is
        begin
            addr(XpixelRange) <= (others=>'0');
            addr(X_RES_SIZE+Y_RES_SIZE-1 downto X_RES_SIZE) <= unsigned(vsync_cnt);
            addr(X_RES_SIZE+Y_RES_SIZE) <= display_buffer_id;
        end;
    begin
        if rst='1' then
            display_buffer_id <= PRIMARY_BUFFER;
            next_display_buffer_id <= PRIMARY_BUFFER;
            draw_buffer_id  <= PRIMARY_BUFFER;
            wr_display      <= '0';
            pixel_data      <= (others=>'0');
            hsync_n_prev    <= '0';
            mem_ready       <= '0';
            cnt             <= (others=>'0');
            display_ready   <= '0';
            state           <= PWR_UP;
            read_cnt        <= (others=>'0');
            write_cnt       <= (others=>'0');
            done_cnt        <= (others=>'0');
            wr_mem          <= '0';
            rd_mem          <= '0';
            addr            <= (others=>'0');
            data_wr_int     <= (others=>'0');
            block_fifo_in   <= (others=>'0');
            read_ack        <= '0';
            read_data       <= (others=>'0');
            flash_wdata     <= (others=>'0');
            flash_rwaddr    <= (others=>'0');
            flash_rdreq     <= '0';
            flash_wreq      <= '0';
            op_ack          <= '0';
            hsync_flag      <= '0';
            refresh_flag    <= '0';
            font_x          <= (others=>'0');
            font_y          <= (others=>'0');
            color           <= (others=>'1');
            transparency_color <= (others=>'0');
            return_rnw_state<= IDLE;
            Reset;
        elsif rising_edge(clk) then
            Reset;
            hsync_n_prev <= hsync_n;
            if unsigned(vsync_cnt)<to_unsigned(Y_RESOLUTION,Y_RES_SIZE) and hsync_flag='1' and display_ready='1' then
                refresh_flag <= '1';
            else
                refresh_flag <= '0';
            end if;
            if hsync_n='0' and hsync_n_prev='1' then
                hsync_flag <= '1';
            end if;
            if status="0100" then
                mem_ready <= '1';
            end if;
            if eof='1' then
                display_ready <= '1';
                display_buffer_id <= next_display_buffer_id;
            end if;
            if read_done='1' then
                read_ack <= '0';
                read_data <= (others=>'0');
            end if;
            if op_busy = '0' then
                op_ack <= '0';
            end if;
            case state is
                when PWR_UP =>
                    if mem_ready='1' then
                        state <= CLEAR_MEM;
                    else
                        state <= PWR_UP;
                    end if;
                when CLEAR_MEM =>
                    wr_mem<='1';
                    addr(X_RES_SIZE+Y_RES_SIZE) <= display_buffer_id;
                    if earlyopBegun='1' then
                        wr_mem<='0';
                        if addr_x=to_unsigned(X_RESOLUTION-1,X_RES_SIZE) then
                            addr(XpixelRange) <= b"0000000000";
                            data_wr_int(XpixelRange) <= b"0000000000";
                            if addr_y=to_unsigned(Y_RESOLUTION-1,Y_RES_SIZE) then
                                addr(YpixelRange) <= b"0000000000";
                                data_wr_int(15 downto 10) <= b"000000";
                                -- if buffer_id=PRIMARY_BUFFER then
                                    -- buffer_id <= BACK_BUFFER;
                                -- else
                                    state <= IDLE;
                                    hsync_flag <= '0'; -- REFRESH STATE should start exactly on next line
                                    wr_mem <='0';
                                --end if;
                            else
                                addr(YpixelRange) <= addr(YpixelRange)+1;
                                --data_wr_int(data_wr_int'high downto YpixelRange'low) <= std_logic_vector(addr(data_wr_int'high downto YpixelRange'low)+1);
                            end if;
                        else
                            addr(XpixelRange) <= addr(XpixelRange)+1;
                            --data_wr_int(XpixelRange) <= std_logic_vector(addr(XpixelRange)+1);
                        end if;
                        -- data_wr_int(15 downto 13) <= std_logic_vector(addr(12 downto 10));
                        -- data_wr_int(10 downto 8) <= std_logic_vector(addr(15 downto 13));
                        -- data_wr_int(4 downto 2) <= std_logic_vector(addr(18 downto 16));
                    end if;
                when REFRESH_DISPLAY =>
                    state <= REFRESH_DISPLAY;
                    if addr(XpixelRange)<to_unsigned(X_RESOLUTION-1,X_RES_SIZE) or (addr(XpixelRange)=to_unsigned(X_RESOLUTION-1,X_RES_SIZE) and earlyOpBegun='0') then
                        rd_mem <= '1';
                    else
                        rd_mem <= '0';
                    end if;
                    addr(X_RES_SIZE+Y_RES_SIZE) <= display_buffer_id;
                    addr(X_RES_SIZE+Y_RES_SIZE-1 downto X_RES_SIZE) <= unsigned(vsync_cnt);
                    if earlyOpBegun='1' then
                        addr(XpixelRange) <= addr(XpixelRange)+1;
                    end if;
                    if done='1' then
                        cnt <= cnt+1;
                        wr_display <= '1';
                        pixel_data <= data_rd;
                        if cnt=to_unsigned(X_RESOLUTION-1,X_RES_SIZE) then
                            state <= WAIT_STATE;
                            refresh_flag <= '0';
                            hsync_flag <= '0';
                            cnt <= (others=>'0');
                            addr <= (others=>'0');
                        end if;
                    end if;
				when WAIT_STATE =>
					if done='1' then
						state <= WAIT_STATE;
					else
						state <= return_rnw_state;
					end if;
                when IDLE =>
                    state <= IDLE;
                    addr <= (others=>'0');
                    if refresh_flag='1' and done='0' then
                        RefreshInterrupt;
                        state <= REFRESH_DISPLAY;
                    elsif done='0' and op_ack='0' then
                        if draw_fifo_empty='0' then
                            addr(X_RES_SIZE+Y_RES_SIZE downto 0) <= unsigned(draw_buffer_id&draw_addr);
                            data_wr_int <= draw_data_out;
                            state <= WRITE_DRAW;
                        elsif op_busy='1' then
                            -- block_fifo_empty is with a 2 clock delay - data_count used instead
                            --if block_data_count/=b"00000000000" then
                            if block_fifo_empty='0' then
                                addr    <= (parameter(3)(7 downto 0)&parameter(4))+write_cnt;
                                state   <= WRITE_MEM_BLOCK;
                            elsif rw_memory_flag=YES then
                                state <= RW_MEMORY;
                                addr <= parameter(0)(7 downto 0)&parameter(1);
                            else
                                addr    <= (parameter(0)(7 downto 0)&parameter(1))+read_cnt;
                                flash_rwaddr <= slv((parameter(0)(5 downto 0)&parameter(1))+read_cnt);
                                state   <= READ_MEM_BLOCK;
                            end if;
                        end if;
                    end if;
                when WRITE_DRAW =>
                    addr(X_RES_SIZE+Y_RES_SIZE downto 0) <= unsigned(draw_buffer_id&draw_addr);
                    data_wr_int <= draw_data_out;
                    wr_mem <= '1';
                    if earlyopBegun='1' then
                        draw_rdreq <= '1';
                        state <= IDLE;
                        addr <= (others=>'0');
                        wr_mem <= '0';
                    end if;
                when READ_MEM_BLOCK =>
                    if earlyopBegun='1' then
                        read_cnt <= read_cnt+1;
                        addr <= addr+1;
                    else
                        addr <= (parameter(0)(7 downto 0)&parameter(1))+read_cnt;
                    end if;
                    if src_mem_type=SDRAM then
                        if refresh_flag='1' then
                            if done='0' then
								RefreshInterrupt;
								return_rnw_state <= READ_MEM_BLOCK;
								if done_cnt=read_cnt and earlyOpBegun='0' then
									state <= REFRESH_DISPLAY;
								else	
									state <= READ_MEM_BLOCK;
								end if;	
                            else
                                state <= READ_MEM_BLOCK;
                                block_fifo_in <= data_rd;
                                block_fifo_wreq <= '1';
                                done_cnt <= done_cnt+1;
                            end if;    
                        else
                            if read_cnt>=block_length or (read_cnt=block_length-1 and earlyOpBegun='1') then
                                rd_mem <= '0';
                            else
                                rd_mem <= '1';
                            end if;
                            if done='1' then
                                block_fifo_in <= data_rd;
                                block_fifo_wreq <= '1';
                                done_cnt <= done_cnt+1;
                            end if;
                            if done_cnt>=block_length then
                                done_cnt <= (others=>'0');
                                read_cnt <= (others=>'0');
                                state <= IDLE;
                                return_rnw_state <= IDLE;
                            end if;
                        end if;    
                    else
                        flash_rdreq<='1';
                        if flash_op_valid='1' then
                            read_cnt <= read_cnt+1;
                            block_fifo_in <= flash_rdata;
                            block_fifo_wreq <= '1';
                            flash_rwaddr<= slv((parameter(0)(5 downto 0)&parameter(1))+read_cnt+1);
                            if read_cnt=block_length-1 then
                                flash_rdreq<='0';
                                state <= IDLE;
                                return_rnw_state <= IDLE;
                                read_cnt <= (others=>'0');
                            elsif refresh_flag='1' then
                                RefreshInterrupt;
                                return_rnw_state <= READ_MEM_BLOCK;
                                state <= REFRESH_DISPLAY;
                                flash_rdreq<='0';    
                            end if;
                        end if;
                    end if;
                when WRITE_MEM_BLOCK =>
                    if earlyopBegun='1' then
                        write_cnt <= write_cnt+1;
                        addr <= addr+1;
                    else
                        addr <= (parameter(3)(7 downto 0)&parameter(4))+write_cnt;
                    end if;
                    if refresh_flag='1' and block_data_count>b"00000000100" then
                        RefreshInterrupt;
                        return_rnw_state <= WRITE_MEM_BLOCK;
                        if done='0' then
                            state <= REFRESH_DISPLAY;
                        end if;
                    else
                        -- data has to be passed next clock cycle after earlyOpBegun , so it has tu be passed straight from block fifo
                        -- read all from block FIFO; we can't use block_fifo_empty because then 1 extra write will be made
                        if (block_data_count=b"00000000001" and earlyopBegun='1') or block_fifo_empty='1' then
                            wr_mem <= '0';
                            if done='0' then
                                write_cnt <= (others=>'0');
                                state <= IDLE;
                                return_rnw_state <= IDLE;
                                addr   <= (others=>'0');
                                op_ack <= '1';
                            end if;
                        else
                            wr_mem <= '1';
                        end if;	
                    end if;
                when RW_MEMORY =>
                    if csr_flag='1' then
                        if rnw_csr='0' then
                            case csr_addr is
                                when CSR_COLOR =>
                                    color <= std_logic_vector(parameter(2));
                                when CSR_FONT_X =>
                                    font_x <= std_logic_vector(parameter(2)(font_x'range));
                                when CSR_FONT_Y =>
                                    font_y <= std_logic_vector(parameter(2)(font_y'range));
                                when TRANSPARENCY =>
                                    transparency_color <= std_logic_vector(parameter(2));
                                when BUFFER_REG =>
                                    next_display_buffer_id <= parameter(2)(0);
                                    draw_buffer_id  <= parameter(2)(8);
                                when CONFIG_REG =>
                                    flash_srst <= parameter(2)(0);
                                when others =>
                                    null;
                            end case;
                        else
                            read_ack <= '1';
                            read_data <= (others=>'0');
                            case csr_addr is
                                when CSR_COLOR =>
                                    read_data <= color;
                                when CSR_FONT_X =>
                                    read_data(font_x'range) <= font_x;
                                when CSR_FONT_Y =>
                                    read_data(font_y'range) <= font_y;
                                when TRANSPARENCY =>
                                    read_data <= transparency_color;
                                when BUFFER_REG =>
                                    read_data(0) <= display_buffer_id;
                                    read_data(8) <= draw_buffer_id;
                                when BUILD_VERSION =>
                                    read_data <= BUILD_NUMBER;
                                when others =>
                                    null;
                            end case;
                        end if;
                        state <= IDLE;
                        op_ack <= '1';
                    elsif src_mem_type=SDRAM then
                        addr <= parameter(0)(7 downto 0)&parameter(1);
                        if read_cnt(0)='0' then
                            if rnw_flag='0' then
                                wr_mem <= '1';
                                data_wr_int<= std_logic_vector(parameter(2));
                            else
                                rd_mem <= '1';
                            end if;
                        else
                            wr_mem <= '0';
                            rd_mem <= '0';
                        end if;
                        if earlyopBegun='1' then
                            read_cnt <= read_cnt+1;
                            wr_mem <= '0';
                            rd_mem <= '0';
                        end if;
                        if done='1' then
                            state <= IDLE;
                            addr <= (others=>'0');
                            wr_mem <= '0';
                            op_ack <= '1';
                            read_cnt <= (others=>'0');
                            if rnw_flag='1' then
                                read_ack<='1';
                                rd_mem <= '0';
                                read_data <= data_rd;
                            end if;
                        end if;
                    else
                        flash_rwaddr<=slv(parameter(0)(5 downto 0)&parameter(1));
                        if rnw_flag='0' then
                            flash_wreq <= '1';
                            flash_wdata <= std_logic_vector(parameter(2));
                        else
                            flash_rdreq <= '1';
                        end if;
                        if flash_op_valid='1' then
                            if rnw_flag='1' then
                                read_ack<='1';
                                read_data <= flash_rdata;
                            end if;
                            op_ack <= '1';
                            state <= IDLE;
                            flash_wreq <= '0';
                            flash_rdreq <= '0';
                            flash_wdata <= (others=>'0');
                        end if;
                    end if;
                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;

    -- 2D operations
    Graphics_operations:process(rst,clk)
    begin
        if rst='1' then
            op_state        <= PWR_UP;
            hostctrl_rdreq  <= '0';
            parameter       <= (others=>(others=>'0'));
            draw_data_in    <= (others=>'0');
            draw_wreq       <= '0';
            transfer_cnt    <= 0;
            rw_memory_flag  <= '0';
            rnw_flag        <= '0';
            csr_flag        <= '0';
            rnw_csr         <= '0';
            letter_no       <= (others=>'0');
            bit_position    <= (others=>'0');
            char_line       <= (others=>'0');
            font_rom_addr   <= (others=>'0');
            x               <= (others=>'0');
            y               <= (others=>'0');
            src_mem_type    <= '0';
            op_busy         <= '0';
			block_length	<= (others=>'0');
            command         <= IDLE;
        elsif rising_edge(clk) then
            hostctrl_rdreq <= '0';
            draw_wreq <= '0';
            -- font_rom_addr = char number & char line
            if letter_no(0)='1' then
               font_rom_addr <= slv(parameter(to_integer(letter_no(3 downto 1))+1)(6 downto 0))&std_logic_vector(char_line);
            else
               font_rom_addr <= slv(parameter(to_integer(letter_no(3 downto 1))+1)(14 downto 8))&std_logic_vector(char_line);
            end if;
            case op_state is
                when PWR_UP =>
                    if mem_ready='1' then
                        op_state <= IDLE;
                    else
                        op_state <= PWR_UP;
                    end if;
                when IDLE =>
                    parameter <= (others=>(others=>'0'));
                    x  <= (others=>'0');
                    y  <= (others=>'0');
                    if hostctrl_empty='0' then
                        op_state <= PARAMETERS_0;
                        hostctrl_rdreq <= '1';
                        parameter(0) <= unsigned(hostctrl_data);
                        transfer_cnt <= 1;
                        case hostctrl_data(CmdRange) is
                            when MEM_COPY =>
                                transfer_limit <= MEM_COPY_SIZE;
                                command <= MEM_COPY_OP;
                            when READ_MEM =>
                                transfer_limit <= READ_MEM_SIZE;
                                command <= READ_MEMORY_REGISTER;
                                rnw_flag <= '1';
                            when WRITE_MEM =>
                                transfer_limit <= WRITE_MEM_SIZE;
                                command <= WRITE_MEMORY_REGISTER;
                                rnw_flag <= '0';
                            when TEXT_STRING =>
                                if hostctrl_data(3 downto 0)/=x"0" then
                                    if hostctrl_data(0)='0' then
                                        transfer_limit <= to_integer(unsigned(hostctrl_data(3 downto 1)))+1;
                                    else
                                        transfer_limit <= to_integer(unsigned(hostctrl_data(3 downto 1)))+2;
                                    end if;
                                    command <= DRAW_TEXT_0;
                                    letter_no <= (others=>'0');
                                    bit_position <= (others=>'0');
                                    char_line <= (others=>'0');
                                    font_rom_addr   <= (others=>'0');
                                else
                                   op_state <= IDLE; 
                                end if;    
                            when others =>
                                op_state <= IDLE;
                                command <= IDLE;
                        end case;
                    else
                        op_state <= IDLE;
                        command <= IDLE;
                    end if;
                when PARAMETERS_0 =>
                    if transfer_cnt=transfer_limit then
						block_length <= parameter(2)(9 downto 0);
                        -- back to IDLE if MEM_COPY command is run with zero-length block
                        if command=MEM_COPY_OP and parameter(2)(9 downto 0)=b"0000000000" then
                            op_state <= IDLE;
                        else
                            op_state <= command;
                        end if;
                    else
                        op_state <= PARAMETERS_1;
                    end if;
                when PARAMETERS_1 =>
                    if hostctrl_empty='0' then
                        hostctrl_rdreq  <= '1';
                        parameter(transfer_cnt) <= unsigned(hostctrl_data);
                        transfer_cnt    <= transfer_cnt+1;
                        op_state    <= PARAMETERS_0;
                    end if;
                -- coordinates are always in order parameter(0)(X_RES_SIZE-1 downto 0)<parameter(2)(X_RES_SIZE-1 downto 0) (set in C library)
                when MEM_COPY_OP =>
                    src_mem_type <= parameter(0)(8);
                    -- source address and destination address are set in other process
                    if op_ack = '1' then
                        op_busy <= '0';
                        op_state <= IDLE;
                    else
                        op_busy <= '1';
                    end if;
                when READ_MEMORY_REGISTER | WRITE_MEMORY_REGISTER =>
                    rw_memory_flag <= '1';
                    rnw_csr <= parameter(0)(10);
                    csr_flag <= parameter(0)(9);
                    src_mem_type <= parameter(0)(8);
                    if op_ack = '1' then
                        op_busy <= '0';
                        op_state <= IDLE;
                        rw_memory_flag <= '0';
                        csr_flag <= '0';
                        rnw_csr <= '0';
                    else
                        op_busy <= '1';
                    end if;
                when DRAW_TEXT_0 =>
                    x <= unsigned(font_x)+(letter_no)*9+bit_position;
                    y <= unsigned(font_y)+(not char_line);
                    op_state <= DRAW_TEXT_1;
                when DRAW_TEXT_1 =>
                    if draw_fifo_full='0' then
                       op_state <= DRAW_TEXT_0;
                        if font_rom_out(to_integer(not bit_position))='1' then
                            if x<to_unsigned(X_RESOLUTION,X_RES_SIZE) and y<to_unsigned(Y_RESOLUTION,Y_RES_SIZE) then
                               draw_data_in <= slv(y)&slv(x)&color;
                               draw_wreq <='1';
                            end if;
                        end if;
                        if bit_position=7 then
                            bit_position <= (others=>'0');
                            op_state <= DRAW_TEXT_2;
                            if char_line = x"F" then
                                if parameter(0)(3 downto 0)=letter_no+1 then
                                   op_state <= IDLE;
                                else
                                   letter_no <= letter_no+1;
                                end if;
                                char_line <= (others=>'0');
                            else
                                char_line <= char_line+1;
                            end if;
                        else
                            bit_position <= bit_position+1;
                        end if;
                    end if;
                when DRAW_TEXT_2 =>
                    op_state <= DRAW_TEXT_0;
                when others =>
                    op_state <= IDLE;
            end case;
        end if;
    end process;
end architecture rtl;
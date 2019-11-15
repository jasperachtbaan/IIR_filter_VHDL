----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/10/2019 09:43:42 AM
-- Design Name: 
-- Module Name: uart_rx - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart_rx is
    generic ( clk_freq : integer;
              baud_rate : integer);
    port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           rx_ser : in STD_LOGIC;
           ready : out STD_LOGIC;
           rx_out : out STD_LOGIC_VECTOR (7 downto 0));
end uart_rx;

architecture Behavioral of uart_rx is
    type STATE_TYPE is (idle, start_bit, get_data, stop_bit);
    type STATE_TYPE_SAMPLE_CLK is (idle, half_delay, make_sample);
    
    signal state : STATE_TYPE;
    signal sample_state : STATE_TYPE_SAMPLE_CLK;
    
    constant regular_sample_delay : integer := clk_freq / baud_rate;
    constant half_sample_delay : integer := clk_freq / (2*baud_rate) - 1;
    
    signal rx_out_buf : STD_LOGIC_VECTOR (7 downto 0);
    signal sample_pulse : STD_LOGIC;
    signal ready_buf : STD_LOGIC;
    signal generate_sample_clk : STD_LOGIC;
    
    
    
begin

    process(clk, rst)
        variable bit_count : integer range 0 to 7;
    begin
        if rising_edge(clk) then
            if (rst = '1') then 
                rx_out_buf <= (others => '0');
                state <= idle;
                ready_buf <= '0';
                generate_sample_clk <= '0';
                bit_count := 0;
            else
                case state is
                    when idle =>
                        bit_count := 0;
                        ready_buf <= '0';
                        generate_sample_clk <= '0';
                        if (rx_ser = '0') then
                            state <= start_bit;
                        else
                            state <= idle;
                        end if;
                        
                    when start_bit =>
                        bit_count := 0;
                        ready_buf <= '0';
                        generate_sample_clk <= '1';
                        if (sample_pulse = '1') and (rx_ser = '0') then
                            --Get the data when the start bit is still low
                            state <= get_data;
                        elsif (sample_pulse = '1') and (rx_ser = '1') then
                            --Go back to idle, start bit not valid
                            state <= idle;
                        else
                            state <= start_bit;
                        end if;
                        
                    when get_data =>
                        rx_out_buf(bit_count) <= rx_ser;
                        ready_buf <= '0';
                        generate_sample_clk <= '1';
                        if (sample_pulse = '1') and (bit_count = 7) then
                            state <= stop_bit;
                            bit_count := 0;
                        elsif (sample_pulse = '1') and (bit_count /= 7) then
                            bit_count := bit_count + 1;
                            state <= get_data;
                        else
                            state <= get_data;
                        end if;
                        
                    when stop_bit =>
                        bit_count := 0;
                        generate_sample_clk <= '1';
                        if (sample_pulse = '1') and (rx_ser = '1') then
                            ready_buf <= '1';
                            state <= idle;
                        elsif (sample_pulse = '1') and (rx_ser = '0') then
                            ready_buf <= '0';
                            state <= idle;
                        else
                            ready_buf <= '0';
                            state <= stop_bit;
                        end if;
                    when others =>
                        bit_count := 0;
                        generate_sample_clk <= '0';
                        ready_buf <= '0';
                        rx_out_buf <= (others => '0');
                        state <= idle;
                end case;
            end if;
        end if;
    end process;
    
    process(clk)
        variable cnt : integer range 0 to regular_sample_delay;
    begin
        if rising_edge(clk) then
            case sample_state is
                when idle =>
                    cnt := 0;
                    sample_pulse <= '0';
                    if (generate_sample_clk = '1') then
                        sample_state <= half_delay;
                    else
                        sample_state <= idle;
                    end if;
                    
                when half_delay =>
                    if (generate_sample_clk = '1') and (cnt = (half_sample_delay - 1)) then
                        cnt := 0;
                        sample_pulse <= '1';
                        sample_state <= make_sample;
                    elsif (generate_sample_clk = '1') and (cnt /= (half_sample_delay - 1)) then
                        cnt := cnt + 1;
                        sample_pulse <= '0';
                        sample_state <= half_delay;
                    else
                        sample_pulse <= '0';
                        sample_state <= idle;
                    end if;
                when make_sample =>
                    if (generate_sample_clk = '1') and (cnt = (regular_sample_delay - 1)) then
                        cnt := 0;
                        sample_pulse <= '1';
                        sample_state <= make_sample;
                    elsif (generate_sample_clk = '1') and (cnt /= (regular_sample_delay - 1)) then
                        cnt := cnt + 1;
                        sample_pulse <= '0';
                        sample_state <= make_sample;
                    else
                        sample_pulse <= '0';
                        sample_state <= idle;
                    end if;
                when others =>
                    sample_state <= idle;
                    cnt := 0;
                    
                end case;
        end if;
    end process;
    
    ready <= ready_buf;
    rx_out <= rx_out_buf;
end Behavioral;

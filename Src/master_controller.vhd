----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/06/2019 05:44:40 PM
-- Design Name: 
-- Module Name: master_controller - Behavioral
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
library work;
use work.SGTL5000_pack.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity master_controller is
    port(clk : in STD_LOGIC;
         rst_inv : in STD_LOGIC;
         sda : inout STD_LOGIC;
         scl : inout STD_LOGIC;
         error_led : out STD_LOGIC;
         rx_sig : in STD_LOGIC;
         MCLK_SGTL5000 : out STD_LOGIC;
         LRCLK_SGTL5000 : out STD_LOGIC;
         BCLK_SGTL5000 : out STD_LOGIC;
         DIN_SGTL5000 : out STD_LOGIC;
         DOUT_SGTL5000 : in STD_LOGIC);
end master_controller;

architecture Behavioral of master_controller is
    type STATE_TYPE is (wait_startup, SGTL5000_setup, running);
    signal state : STATE_TYPE;

    signal reg_write_start : STD_LOGIC;
    signal reg_write_busy : STD_LOGIC;
    signal reg_write_finished : STD_LOGIC;
    signal reg_write_ack_error : STD_LOGIC;
    
    signal rst : STD_LOGIC;
    signal MCLK_SGTL5000_buf : STD_LOGIC;
    
    signal data_buf : STD_LOGIC_VECTOR (15 downto 0);
    signal addr_buf : STD_LOGIC_VECTOR (15 downto 0);
    
    signal startupCount : integer range 0 to 100000;
    signal setupCount : integer range 0 to setup_num;
    
    constant n : integer := 24;
    signal in_data : STD_LOGIC_VECTOR ((n - 1) downto 0);
    signal out_data : STD_LOGIC_VECTOR ((n - 1) downto 0);
    
    signal i2s_reset_inv : STD_LOGIC;
    signal LRCLK : STD_LOGIC;
    
    begin
    SGTL5000_1 : entity work.SGTL5000_reg_write
    generic map(input_clk => 24_000_000,
                bus_clk => 50_000)
    port map(clk => clk,
             rst => rst,
             addr => addr_buf,
             data => data_buf,
             start => reg_write_start,
             busy => reg_write_busy,
             finished => reg_write_finished,
             ack_error => reg_write_ack_error,
             sda => sda,
             scl => scl);

    i2s_1 : entity work.i2s_transceiver
    generic map(mclk_sclk_ratio => 4,
                sclk_ws_ratio => 64,
                d_width => 24)
    port map(reset_n => i2s_reset_inv,
             mclk => MCLK_SGTL5000_buf,
             sclk => BCLK_SGTL5000,
             ws => LRCLK,
             sd_tx => DIN_SGTL5000,
             sd_rx => DOUT_SGTL5000,
             l_data_tx => out_data,
             r_data_tx => out_data,
             l_data_rx => in_data,
             r_data_rx => open);
             
    iir1 : entity work.iir_2nd_order
    generic map(n)
    port map(clk,
             rst,
             LRCLK,
             in_data,
             out_data);
                    
             
    process (clk, rst)
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                reg_write_start <= '0';
                MCLK_SGTL5000_buf <= '0';
                data_buf <= (others => '0');
                addr_buf <= (others => '0');
                state <= wait_startup;
                startupCount <= 0;
                setupCount <= 0;
                i2s_reset_inv <= '0';
            else
            	MCLK_SGTL5000_buf <= not(MCLK_SGTL5000_buf);
                case state is
                    when wait_startup =>
                        reg_write_start <= '0';
                        data_buf <= (others => '0');
                        addr_buf <= (others => '0');
                        i2s_reset_inv <= '0';
                        --setupCount <= 0;
                        
                        if (startupCount = 99999) then
                            state <= SGTL5000_setup;
                            startupCount <= 0;
                      	else
                            state <= wait_startup;
                            startupCount <= startupCount + 1;
                        end if;
                        
                        
                    when SGTL5000_setup =>
                        data_buf <= SGTL5000_settings(setupCount)(15 downto 0); 
                        addr_buf <= SGTL5000_settings(setupCount)(31 downto 16);
                        i2s_reset_inv <= '0';
                        if (reg_write_busy = '0') then
                            reg_write_start <= '1';
                        else
                            reg_write_start <= '0';
                        end if;
                        
                        if (reg_write_finished = '1') and (setupCount = (setup_num - 1)) then
                            state <= running;
                            setupCount <= 0;
                        elsif (reg_write_finished = '1') and (setupCount /= setup_num) then
                            state <= wait_startup;
                            setupCount <= setupCount + 1;
                        else
                            state <= SGTL5000_setup;
                        end if;
                                            
                    when running =>
                    	data_buf <= (others => '0');
                    	data_buf <= (others => '0');
                    	i2s_reset_inv <= '1';
                        state <= running;
                        reg_write_start <= '0';
                        
                    when others =>
                        data_buf <= (others => '0');
                        data_buf <= (others => '0');
                        i2s_reset_inv <= '0';
                        state <= running;
                        reg_write_start <= '0';
                end case;
            end if;
        end if;
    end process;
    
    rst <= not(rst_inv); --Board has an active low reset button
    error_led <= reg_write_ack_error;
    MCLK_SGTL5000 <= MCLK_SGTL5000_buf;
    LRCLK_SGTL5000 <= LRCLK;
end Behavioral;

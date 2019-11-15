----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/06/2019 06:41:04 PM
-- Design Name: 
-- Module Name: SGTL5000_reg_write_tb - Behavioral
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

entity SGTL5000_reg_write_tb is
--  Port ( );
end SGTL5000_reg_write_tb;

architecture Behavioral of SGTL5000_reg_write_tb is
    signal clk : STD_LOGIC;
    signal rst : STD_LOGIC;
    signal start : STD_LOGIC;
    signal busy : STD_LOGIC;
    signal finished : STD_LOGIC;
    signal ack_error : STD_LOGIC;
    signal sda : STD_LOGIC;
    signal scl : STD_LOGIC;
begin
    SGTL5000_1 : entity work.SGTL5000_reg_write
    generic map(input_clk => 24_000_000,
                bus_clk => 400)
    port map(clk => clk,
             rst => rst,
             addr => "1011001110101111",
             data => "0011001100110011",
             start => start,
             busy => busy,
             finished => finished,
             ack_error => ack_error,
             sda => sda,
             scl => scl);
            
    rst <= '1', '0' after 100ns;
    start <= '0', '1' after 200ns, '0' after 300ns;
    process
    begin
        clk <= '1';
        wait for 20.8333333ns;
        clk <= '0';
        wait for 20.8333333ns;
    end process;

end Behavioral;

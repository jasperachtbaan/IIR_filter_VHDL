----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/06/2019 11:30:20 PM
-- Design Name: 
-- Module Name: master_controller_tb - Behavioral
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

entity master_controller_tb is
--  Port ( );
end master_controller_tb;

architecture Behavioral of master_controller_tb is
    signal clk : STD_LOGIC;
    signal rst_inv : STD_LOGIC;
    signal sda : STD_LOGIC;
    signal scl : STD_LOGIC;
    signal error_led : STD_LOGIC;
    signal MCLK_SGTL5000 : STD_LOGIC;
    signal LRCLK_SGTL5000 : STD_LOGIC;
    signal BCLK_SGTL5000 : STD_LOGIC;
    signal DIN_SGTL5000 : STD_LOGIC;
begin

    master_1 : entity work.master_controller
    port map (clk => clk,
              rst_inv => rst_inv,
              sda => sda,
              scl => scl,
              error_led => error_led,
              rx_sig => '0',
              MCLK_SGTL5000 => MCLK_SGTL5000,
              LRCLK_SGTL5000 => LRCLK_SGTL5000,
              BCLK_SGTL5000 => BCLK_SGTL5000,
              DIN_SGTL5000 => DIN_SGTL5000,
              DOUT_SGTL5000 => '0');
    
    process
    begin
        clk <= '1';
        wait for 20.8333333ns;
        clk <= '0';
        wait for 20.8333333ns;
    end process;
    
    rst_inv <= '0', '1' after 100ns;
end Behavioral;

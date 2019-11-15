----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/10/2019 10:39:27 AM
-- Design Name: 
-- Module Name: uart_rx_tb - Behavioral
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

entity uart_rx_tb is
--  Port ( );
end uart_rx_tb;

architecture Behavioral of uart_rx_tb is
    signal clk : STD_LOGIC;
    signal rst : STD_LOGIC;
    signal rx_ser : STD_LOGIC;
    signal ready : STD_LOGIC;
    signal rx_out : STD_LOGIC_VECTOR (7 downto 0);
begin
    uart_rx_1 : entity work.uart_rx
    generic map ( clk_freq => 24E6,
                  baud_rate => 500E3)
    port map (clk => clk,       
              rst => rst,       
              rx_ser => rx_ser, 
              ready => ready,   
              rx_out => rx_out);
              
    rst <= '1', '0' after 100ns;
    
    process
    begin
        rx_ser <= '1';
        wait for 10us;
        
        rx_ser <= '0'; --Start
        wait for 2us;
        
        --Data bits
        rx_ser <= '1';
        wait for 2us;
        rx_ser <= '0';
        wait for 2us; 
        rx_ser <= '1';
        wait for 2us; 
        rx_ser <= '0';
        wait for 2us; 
        rx_ser <= '1';
        wait for 2us; 
        rx_ser <= '0';
        wait for 2us; 
        rx_ser <= '1';
        wait for 2us; 
        rx_ser <= '0';
        wait for 2us;
        
        
        rx_ser <= '1'; --Stop bit
        wait for 2us; 
        
    end process;
    
    process
    begin
        clk <= '1';
        wait for 20.8333333ns;
        clk <= '0';
        wait for 20.8333333ns;
    end process;
      
     
     
    
end Behavioral;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/30/2019 06:35:18 PM
-- Design Name: 
-- Module Name: tb_accumulator - Behavioral
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

entity tb_accumulator is
--  Port ( );
end tb_accumulator;

architecture Behavioral of tb_accumulator is
    constant n : integer := 8;
    
    signal clk : STD_LOGIC;
    signal rst : STD_LOGIC;
    signal sig_in : STD_LOGIC_VECTOR ((n - 1) downto 0);
    signal sig_out : STD_LOGIC_VECTOR ((n - 1) downto 0);
    signal set : STD_LOGIC;
    signal add : STD_LOGIC;
    
begin
    acc1 : entity work.accumulator
    generic map (n)
    port map(clk,
             rst,
             sig_in,
             sig_out,
             set,
             add);
             
    rst <= '1', '0' after 100ns;
    set <= '0', '1' after 200ns, '0' after 210ns;
    add <= '0', '0' after 120ns, '1' after 130ns, '1' after 140ns, '0' after 150ns, '1' after 230ns, '0' after 240ns;
    
    sig_in <= "01011011", "00011011" after 140ns, "00000001" after 160ns, "10100111" after 200ns, "01010101" after 230ns;
    
    process
        begin
            clk <= '1';
            wait for 5ns;
            clk <= '0';
            wait for 5ns;
        end process;
end Behavioral;

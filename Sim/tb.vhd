----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/28/2019 11:29:55 PM
-- Design Name: 
-- Module Name: tb - Behavioral
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
USE ieee.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb is
--  Port ( );
end tb;

architecture Behavioral of tb is
     
     constant n : integer := 24;
     
     signal rst : STD_LOGIC;
     signal clk : STD_LOGIC;
     signal in1 : STD_LOGIC_VECTOR ((n - 1) downto 0);
     signal in2 : STD_LOGIC_VECTOR ((n - 1) downto 0);
     signal go : STD_LOGIC;
     signal res : STD_LOGIC_VECTOR ((2*n - 1) downto 0);
     signal ready : STD_LOGIC;
    
begin
    mult1 : entity work.fp_mult
    generic map(n)
    port map(rst,
             clk,
             in1,
             in2,
             go,
             res,
             ready);
             
             
    rst <= '1', '0' after 100ns;
    go <= '0', '1' after 120ns, '0' after 130ns;
    in1 <= "100101010100111001010101";
    in2 <= "010111011011000011110101";
    
    process
    begin
        clk <= '0';
        wait for 5ns;
        clk <= '1';
        wait for 5ns;
    end process;

end Behavioral;

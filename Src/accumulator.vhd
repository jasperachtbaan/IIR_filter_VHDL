----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/30/2019 06:26:07 PM
-- Design Name: 
-- Module Name: accumulator - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity accumulator is
    generic (n : integer);
    port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           sig_in : in STD_LOGIC_VECTOR ((n - 1) downto 0);
           sig_out : out STD_LOGIC_VECTOR ((n - 1) downto 0);
           set : in STD_LOGIC;
           add : in STD_LOGIC);
end accumulator;

architecture Behavioral of accumulator is
    signal sig_out_buf : STD_LOGIC_VECTOR ((n - 1) downto 0);
    
begin
    
    process(clk, rst)
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                sig_out_buf <= (others => '0');
            else
                if (set = '1') then
                    sig_out_buf <= sig_in;
                elsif (add = '1') then
                    sig_out_buf <= std_logic_vector(signed(sig_out_buf) + signed(sig_in));
                end if;     
            end if; 
        end if;
    end process;
    
    sig_out <= sig_out_buf;
end Behavioral;

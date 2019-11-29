----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/30/2019 08:45:50 PM
-- Design Name: 
-- Module Name: tb_iir - Behavioral
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
use STD.textio.all;
use ieee.std_logic_textio.all;
use IEEE.std_logic_signed.all;
USE ieee.NUMERIC_STD.ALL;

entity tb_iir is
--  Port ( );
end tb_iir;

architecture Behavioral of tb_iir is
    constant n : integer := 24;
    
    signal clk : STD_LOGIC;
    signal rst : STD_LOGIC;
    signal clk_48k : STD_LOGIC;
    signal data_in : STD_LOGIC_VECTOR((n - 1) downto 0);
    signal data_out : STD_LOGIC_VECTOR((n - 1) downto 0);
    
    file file_VECTORS : text;
    file file_RESULTS : text;
    
begin
    iir1 : entity work.iir_2nd_order
    generic map(n)
    port map(clk,
             rst,
             clk_48k,
             data_in,
             data_out);

    process
    begin
        clk <= '1';
        wait for 20.8333333ns;
        clk <= '0';
        wait for 20.8333333ns;
    end process;
    
    
    process
        variable v_ILINE     : line;
        variable v_OLINE     : line;
        variable audio_sig : std_logic_vector((n - 1) downto 0);
    begin
        file_open(file_VECTORS, "Lovestad.bin",  read_mode);
        --file_open(file_RESULTS, "output_results.txt", write_mode);
        
        while not endfile(file_VECTORS) loop
            readline(file_VECTORS, v_ILINE);
            read(v_ILINE, audio_sig);
            --data_in <= audio_sig;
            data_in <= "011111111111111111111111";
            
            write(v_OLINE, conv_integer(data_out), right, n);
           -- writeline(file_RESULTS, v_OLINE);
            
            clk_48k <= '1';
            wait for 5.20833335us; --96kHz
            --wait for 10.4166667us; --48kHz
            clk_48k <= '0';
            wait for 5.20833335us; --96kHz
            --wait for 10.4166667us; --48kHz
        end loop;
        
        file_close(file_VECTORS);
        --file_close(file_VECTORS);
    end process;
    
    rst <= '1', '0' after 100ns;
    
    
end Behavioral;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Jasper Insinger
-- 
-- Create Date: 10/28/2019 08:30:57 PM
-- Design Name: 
-- Module Name: fp_mult - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description:
--This module is a simple n-bit fixed point two's complement multiplier.
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

entity fp_mult is
    Generic(n : integer := 24;
            split_num : integer := 6);
            --A split num of 1 will make n - 1 different additions
            --A split num of a will make n/a - 1 different additions
    Port ( rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           in1 : in STD_LOGIC_VECTOR ((n - 1) downto 0);
           in2 : in STD_LOGIC_VECTOR ((n - 1) downto 0);
           go : in STD_LOGIC;
           res : out STD_LOGIC_VECTOR ((2*n - 1) downto 0);
           ready : out STD_LOGIC);
end fp_mult;

architecture Behavioral of fp_mult is
    TYPE STATE_TYPE is (idle, prep, processing, finalize);
    
    signal state : STATE_TYPE;
    signal accum : STD_LOGIC_VECTOR((2*n - 1) downto 0);
    
    --Define signals to buffer the inputs and the signs of the inputs
    signal in1_buf : STD_LOGIC_VECTOR((n - 1) downto 0);
    --The in2_buf is twice as large to accomodate the bit shifting
    signal in2_buf : STD_LOGIC_VECTOR((2*n - 1) downto 0);
    signal in1_sign : STD_LOGIC;
    signal in2_sign : STD_LOGIC;

    --Define buffer signals for the outputs
    signal res_buf : STD_LOGIC_VECTOR((2*n - 1) downto 0);
    signal ready_buf : STD_LOGIC;
    
    signal count : integer range 0 to n;
    
begin
    
    process(clk, rst)
        variable accum_temp : STD_LOGIC_VECTOR((2*n - 1) downto 0) := (others => '0');
        variable in2_buf_temp : STD_LOGIC_VECTOR((2*n - 1) downto 0) := (others => '0');
    begin
        --This module uses a synchronous reset
        if (rising_edge(clk)) then
            if (rst = '1') then
                res_buf <= (others => '0');
                
                accum <= (others => '0');
                in1_buf <= (others => '0');
                in2_buf <= (others => '0');
                in1_sign <= '0';
                in2_sign <= '0';
                
                state <= idle;
                count <= 0;
                ready_buf <= '0';
            else
                case state is
                    when idle =>
                        accum <= (others => '0');
                        in1_buf <= (others => '0');
                        in2_buf <= (others => '0');
                        in1_sign <= '0';
                        in2_sign <= '0';
                        
                        count <= 0;
                        ready_buf <= '0';
                        if (go = '1') then
                            state <= prep;
                        else
                            state <= idle;
                        end if;
                    
                    when prep =>
                        --First of all make the input buffers ready for multiplication
                        --res_buf <= (others => '0');

                        accum <= (others => '0');
                        
                        if (in1(n - 1) = '1') then
                            in1_buf <= std_logic_vector(unsigned(not(in1)) + 1);
                        else
                            in1_buf <= in1;
                        end if;
                        
                        if (in2(n - 1) = '1') then
                            in2_buf((n - 1) downto 0) <= std_logic_vector(unsigned(not(in2)) + 1);
                        else
                            in2_buf((n - 1) downto 0) <= in2;
                        end if;
                        
                        in2_buf((2*n - 1) downto n) <= (others => '0');
                        in1_sign <= in1(n - 1);
                        in2_sign <= in2(n - 1);
                        
                        state <= processing;
                        count <= 0;
                        ready_buf <= '0';
                        
                    when processing =>
                        --res_buf <= (others => '0');
                        accum_temp := accum;
                        in2_buf_temp := in2_buf;
                        --If the in1_buf signal is high at some bit add the shifted in2_buf to the accumulator
                        for i in 0 to (split_num - 1) loop
                            if (in1_buf(count + i) = '1') then
                                accum_temp := std_logic_vector(unsigned(accum_temp) + unsigned(in2_buf_temp));
                            end if;
                            --The input buffer is shifted left every clock cycle
                            in2_buf_temp := in2_buf_temp((in2_buf'length - 2) downto 0) & '0';
                        end loop;
                        
                        in2_buf <= in2_buf_temp;
                        accum <= accum_temp;
                        count <= count + split_num;
                        
                        ready_buf <= '0';
                        
                        if (count = (n - split_num)) then
                            state <= finalize;
                        else
                            state <= processing;
                        end if;
                        
                    when finalize =>
                        --Take care of the sign and convert result to two's complement if necessary
                        if (in1_sign XOR in2_sign) = '1' then
                            res_buf <= std_logic_vector(unsigned(not(accum)) + 1);
                        else
                            res_buf <= accum;
                        end if;
                        accum <= (others => '0');
                        in1_buf <= (others => '0');
                        in2_buf <= (others => '0');
                        
                        in1_sign <= '0';
                        in2_sign <= '0';
                        
                        state <= idle;
                        count <= 0;
                        ready_buf <= '1';
                        
                    when others =>
                        res_buf <= (others => '0');
                                    
                        accum <= (others => '0');
                        in1_buf <= (others => '0');
                        in2_buf <= (others => '0');
                        in1_sign <= '0';
                        in2_sign <= '0';
                        
                        state <= idle;
                        count <= 0;
                        ready_buf <= '0';
                end case;
            end if;           
        end if;
    end process;
    
    res <= res_buf;
    ready <= ready_buf;
end Behavioral;

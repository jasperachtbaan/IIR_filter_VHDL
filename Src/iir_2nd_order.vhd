----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Jasper Insinger
-- 
-- Create Date: 10/30/2019 11:51:32 AM
-- Design Name: 
-- Module Name: iir_2nd_order - Behavioral
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

entity iir_2nd_order is
    generic( n : integer := 24;
             extra_bits_coeff : integer := 2;
             extra_bits_error : integer := 2);
             --Extra bits sign adds internal bits for accomodating larger coefficient values,
             --an extra_bits_coeff of 1 will accomodate coefficients of 2 for example
             
             --extra_bits_error adds extra internal bits for rounding errors
             
             --The total bit format for data_in and data_out is always Qn-1 (1 sign bit, n-1 fractional bits)
             --The internal bit format is Q extra_bits_coeff.(n + extra_bits_error - 1) (1 sign bit, 
             --extra_bits_coeff integer bits and n + extra_bits_error - 1 fractional bits)
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           clk_48k : in STD_LOGIC;
           data_in : in STD_LOGIC_VECTOR (23 downto 0);
           data_out : out STD_LOGIC_VECTOR (23 downto 0));
end iir_2nd_order;

architecture Behavioral of iir_2nd_order is
    
    TYPE STATE_TYPE is (idle, xb0, xb1, xb2, xa1, xa2, wait_clk48);
    constant m : integer := n + extra_bits_coeff + extra_bits_error;
    
    signal state : STATE_TYPE;
     
    signal in1_mult1 : STD_LOGIC_VECTOR ((m - 1) downto 0);
    signal in2_mult1 : STD_LOGIC_VECTOR ((m - 1) downto 0);
    signal go_mult1 : STD_LOGIC;
    signal res_mult1 : STD_LOGIC_VECTOR ((2*m - 1) downto 0);
    signal ready_mult1 : STD_LOGIC;
    
    signal go_flag : STD_LOGIC;
    
    signal out_buf : STD_LOGIC_VECTOR ((m - 1) downto 0);
    
    signal data_in_buf : STD_LOGIC_VECTOR ((m - 1) downto 0);
    signal data_out_buf : STD_LOGIC_VECTOR ((n - 1) downto 0);
    
    constant b0 : STD_LOGIC_VECTOR ((m - 1) downto 0) := "00100110011101111010001100";
    constant b1 : STD_LOGIC_VECTOR ((m - 1) downto 0) := "10110011100001101100001011";
    constant b2 : STD_LOGIC_VECTOR ((m - 1) downto 0) := "00100110000000100100111001";
    constant a1 : STD_LOGIC_VECTOR ((m - 1) downto 0) := "01111110110110100010110110";
    constant a2 : STD_LOGIC_VECTOR ((m - 1) downto 0) := "11000001001000110011011000";
    
    signal rst_acc1 : STD_LOGIC;
    signal in_acc1 : STD_LOGIC_VECTOR ((m - 1) downto 0);
    signal out_acc1 : STD_LOGIC_VECTOR ((m - 1) downto 0);
    signal set_acc1 : STD_LOGIC;
    signal add_acc1 :  STD_LOGIC;
    
    signal rst_acc2 : STD_LOGIC;
    signal in_acc2 : STD_LOGIC_VECTOR ((m - 1) downto 0);
    signal out_acc2 : STD_LOGIC_VECTOR ((m - 1) downto 0);
    signal set_acc2 : STD_LOGIC;
    signal add_acc2 :  STD_LOGIC;

begin

    mult1 : entity work.fp_mult
    generic map(n => m,
                split_num => 1)
    port map(rst => rst,
             clk => clk,
             in1 => in1_mult1,
             in2 => in2_mult1,
             go => go_mult1,
             res => res_mult1,
             ready => ready_mult1);
             
    acc1 : entity work.accumulator
    generic map (m)
    port map(clk => clk,
             rst => rst_acc1,
             sig_in => in_acc1,
             sig_out => out_acc1,
             set => set_acc1,
             add => add_acc1);
    
    acc2 : entity work.accumulator  
    generic map (m)                 
    port map(clk => clk,            
             rst => rst_acc2,       
             sig_in => in_acc2,     
             sig_out => out_acc2,    
             set => set_acc2,       
             add => add_acc2);         
                   
    process(clk, rst)
    begin
        if (rising_edge(clk)) then
            if (rst = '1') then
                state <= idle;
                in1_mult1 <= (others => '0');
                in2_mult1 <= (others => '0');
                go_mult1 <= '0';
                go_flag <= '0';
                
                rst_acc1 <= '1';
                in_acc1 <= (others => '0');
                add_acc1 <= '0';
                set_acc1 <= '0';
                
                rst_acc2 <= '1';
                in_acc2 <= (others => '0');
                add_acc2 <= '0';
                set_acc2 <= '0';
                
                out_buf <= (others => '0');
                
            else
                case state is
                    when idle =>
                        in1_mult1 <= (others => '0');
                        in2_mult1 <= (others => '0');
                        go_mult1 <= '0';
                        go_flag <= '0';
                        
                        rst_acc1 <= '0';
                        in_acc1 <= (others => '0');
                        add_acc1 <= '0';
                        set_acc1 <= '0';
                        
                        rst_acc2 <= '0';
                        in_acc2 <= (others => '0');
                        add_acc2 <= '0';
                        set_acc2 <= '0';
                    
                        if (clk_48k = '1') then
                            state <= xb0;
                        else
                            state <= idle;
                        end if;
                        
                    when xb0 =>
                        in1_mult1 <= data_in_buf;
                        in2_mult1 <= b0;
                        if (go_flag = '0') then
                            go_mult1 <= '1';
                        else
                            go_mult1 <= '0';
                        end if;
                        
                        rst_acc1 <= '0';
                        in_acc1 <= (others => '0');
                        add_acc1 <= '0';
                        set_acc1 <= '0';
                        
                        rst_acc2 <= '0';
                        in_acc2 <= (others => '0');
                        add_acc2 <= '0';
                        set_acc2 <= '0';
                        if (ready_mult1 = '1') then
                            state <= xb1;
                            out_buf <= std_logic_vector(signed(res_mult1((2*m - 1)) & res_mult1((2*(n + extra_bits_error - 1) + extra_bits_coeff - 1) downto (n + extra_bits_error - 1))) + signed(out_acc1));
                            go_flag <= '0';
                        else
                            state <= xb0;
                            go_flag <= '1';
                        end if;
                                             
                    when xb1 =>
                        in1_mult1 <= data_in_buf;
                        in2_mult1 <= b1;
                        if (go_flag = '0') then
                            go_mult1 <= '1';
                        else
                            go_mult1 <= '0';
                        end if;
                        
                        rst_acc1 <= '0';
                        --in_acc1 <= (others => '0');
                        add_acc1 <= '0';
                        --set_acc1 <= '0';
                        
                        rst_acc2 <= '0';
                        in_acc2 <= (others => '0');
                        add_acc2 <= '0';
                        set_acc2 <= '0';
                        
                        if (ready_mult1 = '1') then
                            state <= xa1;
                            
                            in_acc1 <= std_logic_vector(signed(res_mult1((2*m - 1)) & res_mult1((2*(n + extra_bits_error - 1) + extra_bits_coeff - 1) downto (n + extra_bits_error - 1))) + signed(out_acc2));
                            set_acc1 <= '1';
                            go_flag <= '0';
                        else
                            state <= xb1;
                            in_acc1 <= (others => '0');
                            set_acc1 <= '0';
                            go_flag <= '1';
                        end if;
                        
                    when xa1 =>
                        in1_mult1 <= out_buf;
                        in2_mult1 <= a1;
                        if (go_flag = '0') then
                            go_mult1 <= '1';
                        else
                            go_mult1 <= '0';
                        end if;
                        
                        
                        rst_acc1 <= '0';
                        in_acc1 <= res_mult1(2*m - 1) & res_mult1((2*(n + extra_bits_error - 1) + extra_bits_coeff - 1) downto (n + extra_bits_error - 1));
                        --add_acc1 <= '0';
                        set_acc1 <= '0';
                        
                        rst_acc2 <= '0';
                        in_acc2 <= (others => '0');
                        add_acc2 <= '0';
                        set_acc2 <= '0';
                        
                        if (ready_mult1 = '1') then
                            state <= xb2;
                            add_acc1 <= '1';
                            go_flag <= '0';
                        else
                            state <= xa1;
                            add_acc1 <= '0';
                            go_flag <= '1';
                        end if;
                        
                    when xb2 =>
                        in1_mult1 <= data_in_buf;
                        in2_mult1 <= b2;
                        if (go_flag = '0') then
                            go_mult1 <= '1';
                        else
                            go_mult1 <= '0';
                        end if;
                        
                        rst_acc1 <= '0';
                        in_acc1 <= (others => '0');
                        add_acc1 <= '0';
                        set_acc1 <= '0';
                        
                        rst_acc2 <= '0';
                        --in_acc2 <= (others => '0');
                        add_acc2 <= '0';
                        --set_acc2 <= '0';
                        
                        if (ready_mult1 = '1') then
                            state <= xa2;
                            in_acc2 <= res_mult1((2*m - 1)) & res_mult1((2*(n + extra_bits_error - 1) + extra_bits_coeff - 1) downto (n + extra_bits_error - 1));
                            set_acc2 <= '1';
                            go_flag <= '0';
                        else
                            state <= xb2;
                            in_acc2 <= (others => '0');
                            set_acc2 <= '0';
                            go_flag <= '1';
                        end if;                  
                        
                    when xa2 =>
                        in1_mult1 <= out_buf;
                        in2_mult1 <= a2;
                        if (go_flag = '0') then
                            go_mult1 <= '1';
                        else
                            go_mult1 <= '0';
                        end if;
                        
                        rst_acc1 <= '0';
                        in_acc1 <= (others => '0');
                        add_acc1 <= '0';
                        set_acc1 <= '0';
                        
                        rst_acc2 <= '0';
                        in_acc2 <= res_mult1((2*m - 1)) & res_mult1((2*(n + extra_bits_error - 1) + extra_bits_coeff - 1) downto (n + extra_bits_error - 1));
                        --add_acc2 <= '0';
                        set_acc2 <= '0';
                        
                        if (ready_mult1 = '1') then
                            state <= wait_clk48;
                            add_acc2 <= '1';
                            go_flag <= '0';
                        else
                            state <= xa2;
                            add_acc2 <= '0';
                            go_flag <= '1';
                        end if;
                        
                    when wait_clk48 =>
                        in1_mult1 <= (others => '0');
                        in2_mult1 <= (others => '0');
                        go_mult1 <= '0';
                        go_flag <= '0';
                        
                        rst_acc1 <= '0';
                        in_acc1 <= (others => '0');
                        add_acc1 <= '0';
                        set_acc1 <= '0';
                        
                        rst_acc2 <= '0';
                        in_acc2 <= (others => '0');
                        add_acc2 <= '0';
                        set_acc2 <= '0';
                    
                        if (clk_48k = '0') then
                            state <= idle;
                        else
                            state <= wait_clk48;
                        end if;
                        
                    when others =>
                        in1_mult1 <= (others => '0');
                        in2_mult1 <= (others => '0');
                        go_mult1 <= '0';
                        go_flag <= '0';
                        
                        rst_acc1 <= '0';
                        in_acc1 <= (others => '0');
                        add_acc1 <= '0';
                        set_acc1 <= '0';
                        
                        rst_acc2 <= '0';
                        in_acc2 <= (others => '0');
                        add_acc2 <= '0';
                        set_acc2 <= '0';
                        state <= idle;
                end case;
            end if;
        end if;
    end process;
    
    process(clk_48k, rst)
    begin
        if (rising_edge(clk_48k)) then
            if (rst = '1') then
                data_in_buf <= (others => '0');
                data_out_buf <= (others => '0');
            else
                data_in_buf((m - 1) downto (m - extra_bits_coeff - 1)) <= (others => data_in(n - 1));
                data_in_buf((m - extra_bits_coeff - 2) downto extra_bits_error) <= data_in((n - 2) downto 0);
                data_in_buf((extra_bits_error - 1) downto 0) <= (others => '0');
                
                data_out_buf <= out_buf(m - 1) & out_buf((m - extra_bits_coeff - 2) downto extra_bits_error);
            end if;
        end if;
    end process;
    
    data_out <= data_out_buf;
end Behavioral;

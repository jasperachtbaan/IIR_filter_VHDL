

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SGTL5000_reg_write is
    generic( input_clk : INTEGER := 24_000_000; --input clock speed from user logic in Hz
             bus_clk   : INTEGER := 400_000);   --speed the i2c bus (scl) will run at in Hz
    port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           addr : in STD_LOGIC_VECTOR (15 downto 0);
           data : in STD_LOGIC_VECTOR (15 downto 0);
           start : in STD_LOGIC;
           busy : out STD_LOGIC;
           finished : out STD_LOGIC; --Will output a 1 clock cycle high signal when the write is complete
           ack_error : out STD_LOGIC;
           sda : inout STD_LOGIC;
           scl : inout STD_LOGIC);
end SGTL5000_reg_write;

architecture Behavioral of SGTL5000_reg_write is
    TYPE STATE_TYPE is (idle, setup_byte1_addr, wait_byte1_addr, setup_byte2_addr, wait_byte2_addr, setup_byte1_data, wait_byte1_data, setup_byte2_data, wait_byte2_data, finalize);
    signal state : STATE_TYPE;
    
    signal addr_buf : STD_LOGIC_VECTOR (15 downto 0);
    signal data_buf : STD_LOGIC_VECTOR (15 downto 0);

    signal start_transaction : STD_LOGIC;
    signal i2c_reset : STD_LOGIC;
    signal i2c_data : STD_LOGIC_VECTOR (7 downto 0);
    signal i2c_addr : STD_LOGIC_VECTOR (6 downto 0);
    signal i2c_rw : STD_LOGIC;
    signal i2c_busy : STD_LOGIC;
    
    signal finished_buf : STD_LOGIC;
    signal busy_buf : STD_LOGIC;
    signal ack_error_buf : STD_LOGIC;
begin
    i2c_1 : entity work.i2c_master
    generic map(input_clk => input_clk,
                bus_clk => bus_clk)
    port map(clk => clk,                    --system clock
             reset_n => i2c_reset,                --active low reset
             ena => start_transaction,                    --latch in command
             addr => "0001010",                   --address of target slave
             rw => '0',                     --'0' is write, '1' is read
             data_wr => i2c_data,                --data to write to slave
             busy => i2c_busy,                   --indicates transaction in progress
             data_rd => open,                 --data read from slave
             ack_error => ack_error_buf,                  --flag if improper acknowledge from slave
             sda => sda,                  --serial data output of i2c bus
             scl => scl);  
    i2c_reset <= not(rst);
    
    process(clk, rst)
        
    
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                start_transaction <= '0';
                finished_buf <= '0';
                i2c_data <= (others => '0');
                
                state <= idle;
            else
                case state is
                    when idle =>
                        start_transaction <= '0';
                        i2c_data <= addr_buf(15 downto 8);
                        busy_buf <= '0';
                        finished_buf <= '0';
                        if (start = '1') then
                            state <= setup_byte1_addr;
                            data_buf <= data;
                            addr_buf <= addr;
                        else
                            state <= idle;
                        end if;
                        
                    when setup_byte1_addr =>
                        i2c_data <= addr_buf(15 downto 8);
                        start_transaction <= '1';
                        busy_buf <= '1';
                        finished_buf <= '0';
                        if i2c_busy = '1' then
                            state <= wait_byte1_addr;
                        else
                            state <= setup_byte1_addr;
                        end if;
                    
                    when wait_byte1_addr =>
                        i2c_data <= addr_buf(7 downto 0);
                        start_transaction <= '1';
                        busy_buf <= '1';
                        finished_buf <= '0';
                        if i2c_busy = '0' then
                            state <= setup_byte2_addr;
                        else
                            state <= wait_byte1_addr;
                        end if;
                    
                    when setup_byte2_addr =>
                        i2c_data <= addr_buf(7 downto 0);
                        start_transaction <= '1';
                        busy_buf <= '1';
                        finished_buf <= '0';
                        if i2c_busy = '1' then
                            state <= wait_byte2_addr;
                        else
                            state <= setup_byte2_addr;
                        end if;
                    
                    when wait_byte2_addr =>
                        i2c_data <= data_buf(15 downto 8);
                        start_transaction <= '1';
                        busy_buf <= '1';
                        finished_buf <= '0';
                        if i2c_busy = '0' then
                            state <= setup_byte1_data;
                        else
                            state <= wait_byte2_addr;
                        end if;
                        
                    when setup_byte1_data =>
                        i2c_data <= data_buf(15 downto 8);
                        start_transaction <= '1';
                        busy_buf <= '1';
                        finished_buf <= '0';
                        if i2c_busy = '1' then
                            state <= wait_byte1_data;
                        else
                            state <= setup_byte1_data;
                        end if;
                    
                    when wait_byte1_data =>
                        i2c_data <= data_buf(7 downto 0);
                        start_transaction <= '1';
                        busy_buf <= '1';
                        finished_buf <= '0';
                        if i2c_busy = '0' then
                            state <= setup_byte2_data;
                        else
                            state <= wait_byte1_data;
                        end if;
                        
                    when setup_byte2_data =>
                        i2c_data <= data_buf(7 downto 0);
                        start_transaction <= '1';
                        busy_buf <= '1';
                        finished_buf <= '0';
                        if i2c_busy = '1' then
                            state <= wait_byte2_data;
                        else
                            state <= setup_byte2_data;
                        end if;
                    
                    when wait_byte2_data =>
                        i2c_data <= data_buf(7 downto 0);
                        start_transaction <= '0';
                        busy_buf <= '1';
                        finished_buf <= '0';
                        if i2c_busy = '0' then
                            state <= finalize;
                        else
                            state <= wait_byte2_data;
                        end if;
                        
                    when finalize =>
                        i2c_data <= (others => '0');
                        start_transaction <= '0';
                        busy_buf <= '1';
                        finished_buf <= '1';
                        state <= idle;
                end case;
                    
            end if;
        end if;
    end process;
    busy <= busy_buf;
    finished <= finished_buf;
    ack_error <= ack_error_buf;
end Behavioral;

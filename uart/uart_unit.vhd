
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_unit is
    Generic (
        DBITS: integer := 8;
        SB_TICKS: integer := 16;
        TRESHOLD_BITS: integer := 9;
        TRESHOLD: integer := 326;
        ADDR_BITS: integer := 2);
        
    Port ( 
        clk, rst: in std_logic;
        rx_i: in std_logic;
        tx_o: out std_logic;
        rx_empty, tx_full: out std_logic;
        tx_data_i: in std_logic_vector(DBITS-1 downto 0);
        rx_data_o: out std_logic_vector(DBITS-1 downto 0);
        tx_uart, rx_uart: in std_logic);
        
end uart_unit;

architecture arch of uart_unit is
component baud_generator is
    Generic ( TRESHOLD_BITS: integer := 10; 
              TRESHOLD: integer := 652);
    
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           en: in STD_LOGIC;
           tick_o : out STD_LOGIC);
end component;

component uart_rx is
    Generic (
        DATA_BITS: integer := 8; 
        STOP_TICKS: integer := 16 -- 1 STOP bit - in number of ticks because of not integer count of bits possible for STOP
    );
    
    Port (
        clk, rst: in STD_LOGIC;
        rx_i: in STD_LOGIC;
        tick_i: in STD_LOGIC;
        data_o: out STD_LOGIC_VECTOR(DATA_BITS-1 downto 0);
        done_o: out STD_LOGIC
    );
end component;

component fifo_buffer is
    Generic (ADDR_BITS: integer := 2; 
            DATA_BITS: integer:= 8);
    Port ( 
        clk, rst: in STD_LOGIC;
        wr_i, rd_i: in STD_LOGIC;
        empty_o, full_o: out STD_LOGIC;
        din: in STD_LOGIC_VECTOR(DATA_BITS-1 downto 0);
        dout: out STD_LOGIC_VECTOR(DATA_BITS-1 downto 0)
    );
end component;

component debounce is
    Port ( sign_in : in STD_LOGIC;
           sign_out : out STD_LOGIC;
           clk, rst : in STD_LOGIC);
end component;

component uart_tx is  
    Generic (
        DBITS: integer := 8;
        SB_TICKS: integer := 16);
    
    Port (
        clk, rst: in std_logic;
        tick_i: in std_logic;
        tx_o: out std_logic;
        start_i: in std_logic;
        data_i: in std_logic_vector(DBITS-1 downto 0);
        done_o: out std_logic
    );
end component;

signal tick: std_logic;
signal rx_data, tx_data: std_logic_vector(DBITS-1 downto 0);
signal rx_fifo_data, tx_fifo_data: std_logic_vector(DBITS-1 downto 0);
signal rx_done, tx_done: std_logic;
signal tx_empty, tx_not_empty: std_logic;

begin
    
    baudrate_gen_inst: baud_generator generic map ( TRESHOLD_BITS=>TRESHOLD_BITS, TRESHOLD=>TRESHOLD) port map (clk=>clk, rst=>rst, en=>'1', tick_o=>tick);
    
    uart_rx_inst: uart_rx generic map (DATA_BITS=>DBITS, STOP_TICKS=>SB_TICKS) port map(clk=>clk, rst=>rst, rx_i=>rx_i, tick_i=>tick, data_o=>rx_data, done_o=>rx_done);

    rx_fifo_inst: fifo_buffer generic map (ADDR_BITS=>ADDR_BITS, DATA_BITS=>DBITS) port map (clk=>clk, rst=>rst, wr_i=>rx_done, rd_i=>rx_uart, empty_o=>rx_empty, full_o=>open, din=>rx_data, dout=>rx_data_o);
    
    tx_fifo_inst: fifo_buffer generic map (ADDR_BITS=>ADDR_BITS, DATA_BITS=>DBITS) port map (clk=>clk, rst=>rst, wr_i=>tx_uart, rd_i=>tx_done, empty_o=>tx_empty, full_o=>tx_full, din=>tx_data_i, dout=>tx_data);
    
    uart_tx_inst: uart_tx generic map (DBITS=>DBITS, SB_TICKS=>SB_TICKS) port map(clk=>clk, rst=>rst, tick_i=>tick, tx_o=>tx_o, start_i=>tx_not_empty, data_i=>tx_data, done_o=>tx_done);

    tx_not_empty <= not tx_empty;
    
end arch;

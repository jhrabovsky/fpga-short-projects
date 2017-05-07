
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_top is
    Port (
        UART_TXD_IN: in std_logic;
        UART_RXD_OUT: out std_logic;
        CLK100MHZ: in std_logic;
        RST: in std_logic;
        LED: out std_logic_vector(9 downto 0);
        BTN: in std_logic;
        AN: out std_logic_vector(7 downto 0));
        
end uart_top;

architecture arch of uart_top is

component uart_unit is
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
end component;

component debounce is
    Port ( sign_in : in STD_LOGIC;
           sign_out : out STD_LOGIC;
           clk, rst : in STD_LOGIC);
end component;

signal rx_empty, tx_full: std_logic;
signal db_btn_r, db_btn_n, btn_edge: std_logic;
signal data: std_logic_vector(7 downto 0);

begin
    db_btn_inst: debounce port map( sign_in=>BTN, sign_out=>db_btn_n, clk=>CLK100MHZ, rst=>RST);

    uart_unit_inst: uart_unit port map (clk=>CLK100MHZ, rst=>RST, rx_i=>UART_TXD_IN, tx_o=>UART_RXD_OUT, rx_empty=>rx_empty, tx_full=>tx_full, tx_data_i=>data, rx_data_o=>data, tx_uart=>btn_edge, rx_uart=>btn_edge);
    
    reg_update: process(CLK100MHZ, RST) is
    begin 
        if (RST = '1') then
            db_btn_r <= '0';
        elsif (rising_edge(CLK100MHZ)) then
            db_btn_r <= db_btn_n;
        end if;
    end process reg_update;
       
    btn_edge <= (not db_btn_r) and (db_btn_n);
    
    LED(7 downto 0) <= data;
    LED(8) <= tx_full;
    LED(9) <= rx_empty;
    
    AN <= "11111111";
        
end arch;

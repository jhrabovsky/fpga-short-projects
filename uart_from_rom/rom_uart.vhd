
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rom_uart is
    Port (
        UART_TXD_IN: in std_logic; -- PC->FPGA
        UART_RXD_OUT: out std_logic; -- FPGA->PC
        CLK100MHZ: in std_logic;
        RST: in std_logic;
        LED: out std_logic_vector(9 downto 0);
        BTN: in std_logic;
        AN: out std_logic_vector(7 downto 0));
        
end rom_uart;

architecture arch of rom_uart is

component counter is
    Generic (
        THRESHOLD : natural
    );
    Port ( CLK_IN : in STD_LOGIC;
           RST: in STD_LOGIC;
           EN : in STD_LOGIC;
           COUNT : out STD_LOGIC_VECTOR(19 downto 0);
           TS : out STD_LOGIC
    );
end component;

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

component mem_reader is
    generic (
        FILENAME : string;
        DATA_LEN : natural;
        ADDR_LEN : natural;
        NO_ITEMS : natural
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        en : in std_logic;
        data : out std_logic_vector(DATA_LEN - 1 downto 0)
    );
end component;

--------------------------
--      CONSTANTS       --
--------------------------

constant DATA_LEN : natural := 8;
constant ADDR_LEN : natural := 6;
constant NO_ITEMS : natural := 10;

--------------------------
--      SIGNALS         --
--------------------------

signal rx_empty, tx_full: std_logic;
signal db_btn_send_r, db_btn_send_n, btn_send_edge: std_logic;
signal data_send, data_recv: std_logic_vector(DATA_LEN - 1 downto 0);
signal btn_recv : std_logic;

begin
    db_btn_send_inst: debounce port map( sign_in=>BTN, sign_out=>db_btn_send_n, clk=>CLK100MHZ, rst=>RST);

    uart_unit_inst: uart_unit port map (clk=>CLK100MHZ, rst=>RST, rx_i=>UART_TXD_IN, tx_o=>UART_RXD_OUT, rx_empty=>rx_empty, tx_full=>tx_full, tx_data_i=>data_send, rx_data_o=>data_recv, tx_uart=>btn_send_edge, rx_uart=>btn_recv);
    
    reg_update: process(CLK100MHZ, RST) is
    begin 
        if (RST = '1') then
            db_btn_send_r <= '0';
        elsif (rising_edge(CLK100MHZ)) then
            db_btn_send_r <= db_btn_send_n;
        end if;
    end process reg_update;
       
    mem_reader_inst : mem_reader
        generic map (
            FILENAME => "rom.data",
            DATA_LEN => DATA_LEN,
            ADDR_LEN => ADDR_LEN,
            NO_ITEMS => NO_ITEMS
        )  
        port map (
            clk => CLK100MHZ,
            rst =>RST,
            en => btn_send_edge,
            data => data_send   
        );

    btn_send_edge <= (not db_btn_send_r) and (db_btn_send_n);
    
    btn_recv <= '0';

    LED(7 downto 0) <= data_send;
    LED(8) <= tx_full;
    LED(9) <= rx_empty;
    
    AN <= "11111111"; -- disable all 7seg displays
        
end arch;

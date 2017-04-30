library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_fibonacci is
    Port ( CLK100MHZ : in STD_LOGIC;
           RST : in STD_LOGIC;
           BT : in STD_LOGIC;
           AN : out STD_LOGIC_VECTOR (7 downto 0);
           SSEG : out STD_LOGIC_VECTOR (7 downto 0);
           START : in STD_LOGIC);
end top_fibonacci;

architecture arch of top_fibonacci is

component debounce is
    Port ( sign_in : in STD_LOGIC;
           sign_out : out STD_LOGIC;
           clk, rst : in STD_LOGIC);
end component;

component fibonacci is
    Port ( clk, rst: in std_logic; 
           tick_i, start_i: in std_logic;
           done_tick: out std_logic;
           fib_o: out unsigned(7 downto 0));
end component;

component Bin_to_BCD is
    Port ( clk, rst, start : in STD_LOGIC;
           data_bin : in STD_LOGIC_VECTOR(7 downto 0);
           data_bcd : out STD_LOGIC_VECTOR(11 downto 0);
           ready, done_tick : out STD_LOGIC);
end component;

component sseg_display is
    Generic ( N: integer := 17;
              mask: in std_logic_vector(7 downto 0));
    
    Port ( hex1 : in STD_LOGIC_VECTOR (3 downto 0);
           hex2 : in STD_LOGIC_VECTOR (3 downto 0);
           hex3 : in STD_LOGIC_VECTOR (3 downto 0);
           hex4 : in STD_LOGIC_VECTOR (3 downto 0);
           hex5 : in STD_LOGIC_VECTOR (3 downto 0);
           hex6 : in STD_LOGIC_VECTOR (3 downto 0);
           hex7 : in STD_LOGIC_VECTOR (3 downto 0);
           hex8 : in STD_LOGIC_VECTOR (3 downto 0);
           clk, rst : in STD_LOGIC;
           sseg : out STD_LOGIC_VECTOR (7 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0));
end component;

signal fib_num_r, fib_num_n, fib_num_tmp: unsigned (7 downto 0);
signal fib_num_v: std_logic_vector (7 downto 0);
signal data_bcd_r, data_bcd_n, data_bcd_tmp: std_logic_vector (11 downto 0);

signal edge_bt, edge_start: std_logic;
signal bt_db_n, start_db_n: std_logic;
signal bt_db_r, start_db_r: std_logic;
signal done_fib, done_bcd: std_logic;
begin
    
    syn_regs: process(CLK100MHZ, RST)
    begin
        if (rst = '1') then
            fib_num_r <= (others=>'0');
            data_bcd_r <= (others=>'0');
            bt_db_r <= '0';
            start_db_r <= '0';
        elsif (rising_edge(CLK100MHZ)) then
            fib_num_r <= fib_num_n;
            data_bcd_r <= data_bcd_n;
            bt_db_r <= bt_db_n;
            start_db_r <= start_db_n;
        end if;
    end process syn_regs;
    
    
    debounce_inst1: debounce port map (sign_in=>BT, sign_out=> bt_db_n, clk=>CLK100MHZ, rst=>RST);
    debounce_inst2: debounce port map (sign_in=>START, sign_out=> start_db_n, clk=>CLK100MHZ, rst=>RST);
    
    edge_bt <= (not bt_db_r) and (bt_db_n);
    edge_start <= (not start_db_r) and (start_db_n);
    
    fib_num_n <= fib_num_tmp when done_fib = '1' else
                 fib_num_r;
                 
    fib_num_v <= std_logic_vector(fib_num_r);
    
    data_bcd_n <= data_bcd_tmp when done_bcd = '1' else
                  data_bcd_r;
                  
    fibonacci_inst: fibonacci port map (clk=>CLK100MHZ, rst=>RST, tick_i=>edge_bt, start_i=>edge_start, done_tick=>done_fib, fib_o=>fib_num_tmp);
    bin_to_bcd_inst: bin_to_bcd port map (clk=>CLK100MHZ, rst=>RST, start=>'1', data_bin=>fib_num_v, data_bcd=>data_bcd_tmp, ready=>open, done_tick=>done_bcd);
    sseg_display_inst: sseg_display generic map (N=>17, mask => "00000111") port map (hex1=>data_bcd_r(3 downto 0), hex2=>data_bcd_r(7 downto 4), hex3=>data_bcd_r(11 downto 8), hex4=>"0000", hex5=>"0000", hex6=>"0000", hex7=>"0000", hex8=>"0000", clk=>CLK100MHZ, rst=>RST, sseg=>SSEG, an=>AN);
    
end arch;

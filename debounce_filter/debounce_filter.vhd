library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity debounce_filter is
    Port ( BT : in STD_LOGIC;
           CLK100MHZ : in STD_LOGIC;
           RST : in STD_LOGIC;
           SSEG : out STD_LOGIC_VECTOR (7 downto 0);
           AN : out STD_LOGIC_VECTOR (7 downto 0));
end debounce_filter;

architecture arch of debounce_filter is
component debounce is
    Port ( sign_in : in STD_LOGIC;
           sign_out : out STD_LOGIC;
           clk, rst : in STD_LOGIC);
end component;

component tick_counter is
    Port ( tick : in STD_LOGIC;
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           tick_count : out STD_LOGIC_VECTOR (7 downto 0));
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

component Bin_to_BCD is
    Port ( clk, rst, start : in STD_LOGIC;
           data_bin : in STD_LOGIC_VECTOR(7 downto 0);
           data_bcd : out STD_LOGIC_VECTOR(11 downto 0);
           ready, done_tick : out STD_LOGIC);
end component;

signal db_bt_sig, db_bt_reg: STD_LOGIC;
signal tick_count_reg, tick_count_tmp: std_logic_vector(7 downto 0);
signal edge: std_logic;
signal tick_count_bcd_reg, tick_count_bcd_next, tick_count_bcd_tmp: std_logic_vector(11 downto 0);
signal done_tick, start, ready: std_logic;

begin
    syn_regs: process(clk100mhz, rst)
    begin
        if (rst = '1') then
            db_bt_reg <= '0';
            tick_count_bcd_reg <= (others=>'0');
            tick_count_reg <= (others=>'0');
        elsif (rising_edge(clk100mhz)) then
            db_bt_reg <= db_bt_sig;
            tick_count_bcd_reg <= tick_count_bcd_next;
            tick_count_reg <= tick_count_tmp; 
        end if;
    end process syn_regs; 
    
    edge <= (not db_bt_reg) and (db_bt_sig);
    
    debounce_inst: debounce port map (sign_in=>bt, sign_out=>db_bt_sig, clk=>clk100mhz, rst=>rst);
    tick_counter_inst: tick_counter port map(tick=>edge, clk=>clk100mhz, rst=>rst, tick_count=>tick_count_tmp);
    bin_to_bcd_inst: bin_to_bcd port map (clk=>clk100mhz, rst=>rst, start=>'1', data_bin=>tick_count_reg, data_bcd=>tick_count_bcd_tmp, ready=>ready, done_tick=>done_tick);
    sseg_display_inst: sseg_display generic map(N=>17, mask=>"00000111") port map(hex1=>tick_count_bcd_reg(3 downto 0), hex2=>tick_count_bcd_reg(7 downto 4), hex3=>tick_count_bcd_reg(11 downto 8), hex4=>"0000", hex5=>"0000", hex6=>"0000", hex7=>"0000", hex8=>"0000", clk=>clk100mhz, rst=>rst, sseg=>sseg, an=>an);

    tick_count_bcd_next <= tick_count_bcd_tmp when done_tick = '1' else
                           tick_count_bcd_reg;
  
end arch;

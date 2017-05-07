library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity blinking_leds_circle is
    Port ( CLK : in STD_LOGIC;
           SEG : out STD_LOGIC_VECTOR (7 downto 0);
           AN : out STD_LOGIC_VECTOR (7 downto 0);
           SW1 : in STD_LOGIC;
           SW2 : in STD_LOGIC);
end blinking_leds_circle;

architecture Behavioral of blinking_leds_circle is

component blinking_led is
port (
		clk: in std_logic;
		rst: in std_logic;
		cw: in std_logic;
		seg: out std_logic_vector(7 downto 0);
		an: out std_logic_vector(7 downto 0)
	);
end component;

component counter is
Port ( CLK_IN : in STD_LOGIC;
           RST: in STD_LOGIC;
           TS : out STD_LOGIC);
end component;

signal clk_1s: STD_LOGIC;
begin
    counter_inst: counter port map (CLK_IN => clk, RST => SW1, TS => clk_1s);
    blinking_led_inst: blinking_led port map (clk => clk_1s, rst => SW1, cw => SW2, seg => SEG, an => AN);
end Behavioral;

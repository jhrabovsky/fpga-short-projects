
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_tb is
end top_tb;

architecture Behavioral of top_tb is

component top is
   port (
      clk,reset: in std_logic;
      hsync, vsync: out  std_logic;
      rgb: out std_logic_vector(11 downto 0)
   );
end component;

constant T : time := 10ns;
signal clk, rst, hsync, vsync : std_logic;
signal rgb : std_logic_vector(11 downto 0);

begin

    uut : top
    port map (
        clk => clk,
        reset => rst,
        hsync => hsync,
        vsync => vsync,
        rgb => rgb
    );

    clk_gen : process is
    begin
        clk <= '0';
        wait for T/2;
        clk <= '1';
        wait for T/2;
    end process clk_gen;
    
    stimuli : process is
    begin
        rst <= '1';
        wait for T;
        rst <= '0';
        wait for T;
        
        wait;
    end process stimuli;
end Behavioral;

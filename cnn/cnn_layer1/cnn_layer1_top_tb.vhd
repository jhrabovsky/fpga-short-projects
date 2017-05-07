
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_tb is
end top_tb;

architecture rtl of top_tb is

component top is
    Port ( 
        CLK100MHZ: in std_logic;
        RST: in std_logic
    );
end component;

constant T : time := 10ns;
signal clk, rst : std_logic;

begin
    uut : top
        port map (
            CLK100MHZ => clk,
            RST => rst
        );
    
    clk_proc : process is
    begin
        clk <= '0';
        wait for T/2;
        clk <= '1';
        wait for T/2;
    end process clk_proc;
    
    stimuli_proc : process is
    begin
        rst <= '1';
        wait for 2*T;
        
        rst <= '0';
        wait;
    end process stimuli_proc;
end rtl;

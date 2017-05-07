
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_tb is
end top_tb;

architecture RTL of top_tb is

component top is
    Port ( 
        CLK100MHZ : in std_logic;
        BTN_RST : in std_logic;
        LED : out std_logic_vector(7 downto 0)
    );
end component;

constant T : time := 10ns;
signal clk, rst : std_logic;
signal led : std_logic_vector(7 downto 0);

begin
    uut : top
        port map (
            CLK100MHZ => clk,
            BTN_RST => rst,
            LED => led
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
        wait for 2*T;
        rst <= '0';
        wait;
    end process stimuli;
end RTL;

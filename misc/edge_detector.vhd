
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity edge_detector is
    Port (
        clk, rst : in std_logic;        
        din : in std_logic;
        edge : out std_logic
    );
end edge_detector;

architecture Behavioral of edge_detector is
signal din_reg : std_logic;
begin
    reg : process (clk, rst) is
    begin
        if (rst = '1') then
            din_reg <= '0';
        elsif (rising_edge(clk)) then
            din_reg <= din;
        end if;
    end process reg;

    edge <= din and (not din_reg);
end Behavioral;

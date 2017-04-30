
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity baud_generator is
    Generic ( TRESHOLD_BITS: integer := 9; 
              TRESHOLD: integer := 326); -- 19200*16 Hz => 100000000/19200*16
    
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           en: in STD_LOGIC;
           tick_o : out STD_LOGIC);
end baud_generator;

architecture arch of baud_generator is

signal count_reg, count_next : unsigned(TRESHOLD_BITS-1 downto 0);

begin
    reg: process (clk, rst) is
    begin
        if (rst = '1') then
            count_reg <= (others => '0');
        elsif (rising_edge(clk)) then
            if (en = '1') then
                count_reg <= count_next;
            end if;
        end if; 
    end process reg;

    count_next <= (others => '0') when (count_reg = TRESHOLD - 1) else
                  count_reg + 1;

    tick_o <= '1' when (count_reg = TRESHOLD-1) else
              '0';
end arch;

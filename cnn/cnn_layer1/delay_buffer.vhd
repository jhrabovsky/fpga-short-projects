
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity delay_buffer is
    Generic (
        LENGTH : natural := 1;
        DATA_WIDTH: natural := 8
    );
    
    Port ( 
        din : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        dout : out std_logic_vector(DATA_WIDTH - 1 downto 0);
        clk, ce : in std_logic 
    );
end delay_buffer;

architecture Behavioral of delay_buffer is

signal buff_reg : std_logic_vector(DATA_WIDTH * LENGTH - 1 downto 0);
 
begin
    
    process (clk) is
    begin
        if (rising_edge(clk)) then
            if (ce = '1') then
                buff_reg <= buff_reg(DATA_WIDTH * (LENGTH-1) - 1 downto 0) & din;
            end if;
        end if; 
    end process;

    dout <= buff_reg(DATA_WIDTH * LENGTH - 1 downto DATA_WIDTH * (LENGTH-1));

end Behavioral;

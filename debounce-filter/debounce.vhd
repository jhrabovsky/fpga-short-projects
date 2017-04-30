library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debounce is
    Port ( sign_in : in STD_LOGIC;
           sign_out : out STD_LOGIC;
           clk, rst : in STD_LOGIC);
end debounce;

architecture arch of debounce is
type state is (zero, wait1, wait0, one);
signal s_reg, s_next: state;
signal tim_reg, tim_next: unsigned (1 downto 0);

constant STABLE_CYCLES_COUNT : unsigned(1 downto 0) := (others=>'1');
begin
    syn_regs: process (clk, rst)
    begin
        if (rst = '1') then
            s_reg <= zero;
            tim_reg <= STABLE_CYCLES_COUNT;
        elsif (rising_edge(clk)) then
            s_reg <= s_next;
            tim_reg <= tim_next;
        end if;
    end process syn_regs;

    state_trans: process (s_reg, sign_in, tim_next, tim_reg)
    begin
        s_next <= s_reg;
        sign_out <= '0';
        tim_next <= tim_reg;
        
        case s_reg is
        when zero =>
            if (sign_in = '1') then
                s_next <= wait1;
                tim_next <= STABLE_CYCLES_COUNT;
            end if;
        when wait1 =>
            sign_out <= '1';
            tim_next <= tim_reg - 1;
            if (tim_next = 0) then
                s_next <= one;
            end if;
        when one =>
            sign_out <= '1';
            if (sign_in = '0') then
                s_next <= wait0;
                tim_next <= STABLE_CYCLES_COUNT;                 
            end if;
        when wait0 =>
            tim_next <= tim_reg - 1;
            if (tim_next = 0) then
                s_next <= zero;                
            end if; 
        end case;
    end process state_trans;

end arch;

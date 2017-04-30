library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fibonacci is
    Port (
        clk, rst: in std_logic; 
        tick_i, start_i: in std_logic;
        done_tick: out std_logic;
        fib_o: out unsigned(7 downto 0)
    );
end fibonacci;

architecture arch of fibonacci is
type state is (idle, op, done);
signal s_n, s_r: state;
signal fib1_r, fib1_n, fib2_r, fib2_n: unsigned(7 downto 0);
begin
    syn_regs: process(clk, rst)
    begin
        if (rst = '1') then
            s_r <= idle;
            fib1_r <= (others=>'0');
            fib2_r <= "00000001";
        elsif (rising_edge(clk)) then
            s_r <= s_n;
            fib1_r <= fib1_n;
            fib2_r <= fib2_n;
        end if;
    end process syn_regs;
    
    fib_upd: process(s_r, fib1_r, fib2_r, tick_i, start_i)
    begin
        s_n <= s_r;
        fib1_n <= fib1_r;
        fib2_n <= fib2_r;
        done_tick <= '0';
        
        case s_r is
        when idle =>
            if (start_i = '1') then
                fib1_n <= (others=>'0');
                fib2_n <= "00000001";
                s_n <= op;
            end if;
        when op =>
            if (tick_i = '1') then
                fib1_n <= fib2_r;
                fib2_n <= fib1_r + fib2_r;
                s_n <= done;
            end if;
        when done =>
            done_tick <= '1';
            s_n <= op;       
        end case;
    end process fib_upd;
    
    fib_o <= fib2_r;
    
end arch;

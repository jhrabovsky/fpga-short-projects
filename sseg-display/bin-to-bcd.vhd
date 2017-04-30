library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Bin_to_BCD is
    Port ( clk, rst, start : in STD_LOGIC;
           data_bin : in STD_LOGIC_VECTOR(7 downto 0);
           data_bcd : out STD_LOGIC_VECTOR(11 downto 0);
           ready, done_tick : out STD_LOGIC);
end Bin_to_BCD;

architecture arch of Bin_to_BCD is
signal bit_count_reg, bit_count_next: unsigned(3 downto 0);
signal bcd1_reg, bcd2_reg, bcd3_reg : unsigned(3 downto 0);
signal bcd1_next, bcd2_next, bcd3_next : unsigned(3 downto 0);
signal bcd1_tmp, bcd2_tmp, bcd3_tmp : unsigned(3 downto 0);
signal dbin_reg, dbin_next: std_logic_vector(7 downto 0);

type state is (idle, update, done);
signal s_reg, s_next: state;
begin
    syn_regs: process(clk, rst)
    begin
        if (rst = '1') then
            s_reg <= idle;
            bcd1_reg <= (others=>'0');
            bcd2_reg <= (others=>'0');
            bcd3_reg <= (others=>'0');
            dbin_reg <= (others=>'0');
        elsif (rising_edge(clk)) then
            s_reg <= s_next;
            bit_count_reg <= bit_count_next;
            bcd1_reg <= bcd1_next;
            bcd2_reg <= bcd2_next;
            bcd3_reg <= bcd3_next;
            dbin_reg <= dbin_next;
        end if;
    end process syn_regs;
    
    bcd_upd: process(s_reg, bcd1_reg, bcd2_reg, bcd3_reg, bit_count_reg, bit_count_next, start)
    begin
        done_tick <= '0';
        s_next <= s_reg;
        ready <= '0';
 
        case s_reg is
        when idle =>
            ready <= '1';
            if (start = '1') then
                s_next <= update;
                bcd1_next <= (others=>'0');
                bcd2_next <= (others=>'0');
                bcd3_next <= (others=>'0');
                bit_count_next <= "1000";
                dbin_next <= data_bin;
            end if;
        when update =>
            if (bit_count_next = 0) then
                s_next <= done;
            else
                bit_count_next <= bit_count_reg - 1;
                dbin_next <= dbin_reg(6 downto 0) & '0';               
                bcd1_next <= bcd1_tmp(2 downto 0) & dbin_reg(7);
                bcd2_next <= bcd2_tmp(2 downto 0) & bcd1_tmp(3);
                bcd3_next <= bcd3_tmp(2 downto 0) & bcd2_tmp(3);  
            end if;       
        when done =>
           done_tick <= '1';
           s_next <= idle;     
        end case;    
    end process bcd_upd;
        
    bcd1_tmp <= bcd1_reg + 3 when bcd1_reg > 4 else
                bcd1_reg;
    
    bcd2_tmp <= bcd2_reg + 3 when bcd2_reg > 4 else
                bcd2_reg;
    
    bcd3_tmp <= bcd3_reg + 3 when bcd3_reg > 4 else
                bcd3_reg;            
    
    data_bcd <= std_logic_vector(bcd3_reg) & std_logic_vector(bcd2_reg) & std_logic_vector(bcd1_reg);
end arch;

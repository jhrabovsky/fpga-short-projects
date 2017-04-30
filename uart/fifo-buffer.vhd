
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fifo_buffer is
    Generic (ADDR_BITS: integer := 2; 
        DATA_BITS: integer:= 8);
    Port ( 
        clk, rst: in STD_LOGIC;
        wr_i, rd_i: in STD_LOGIC;
        empty_o, full_o: out STD_LOGIC;
        din: in STD_LOGIC_VECTOR(DATA_BITS-1 downto 0);
        dout: out STD_LOGIC_VECTOR(DATA_BITS-1 downto 0)
    );
end fifo_buffer;

architecture arch of fifo_buffer is

type mem_array is array (2**ADDR_BITS-1 downto 0) of STD_LOGIC_VECTOR(DATA_BITS-1 downto 0);
signal buff: mem_array;

signal wr_addr_n, wr_addr_r: STD_LOGIC_VECTOR(ADDR_BITS-1 downto 0);
signal rd_addr_n, rd_addr_r: STD_LOGIC_VECTOR(ADDR_BITS-1 downto 0);

signal empty_r, empty_n, full_r, full_n: STD_LOGIC;
signal wr_en: STD_LOGIC;

signal rd_addr_succ, wr_addr_succ: STD_LOGIC_VECTOR(ADDR_BITS-1 downto 0);
signal op: STD_LOGIC_VECTOR(1 downto 0);

begin
    regs_update: process(clk, rst) is
    begin
        if (rst = '1') then
            wr_addr_r <= (others=>'0');
            rd_addr_r <= (others=>'0');        
            empty_r <= '1';
            full_r <= '0'; 
        elsif (rising_edge(clk)) then
            wr_addr_r <= wr_addr_n;
            rd_addr_r <= rd_addr_n;
            empty_r <= empty_n;
            full_r <= full_n;
        end if;
    end process regs_update; 

    mem_update: process (clk, rst) is
    begin
        if (rst = '1') then
            -- clear internal buffer memory
            buff <= (others => (others => '0'));    
        elsif (rising_edge(clk)) then
            if (wr_en = '1') then
                buff(to_integer(unsigned(wr_addr_r))) <= din;
            end if;    
        end if;
    end process mem_update;
    
    wr_en <= wr_i and (not full_r);
    dout <= buff(to_integer(unsigned(rd_addr_r)));
    
    rd_addr_succ <= std_logic_vector(unsigned(rd_addr_r) + 1);
    wr_addr_succ <= std_logic_vector(unsigned(wr_addr_r) + 1);
    
    op <= wr_i & rd_i;
    
    control_logic: process(op, empty_r, full_r, rd_addr_succ, wr_addr_succ, wr_addr_r, rd_addr_r) is
    begin
        rd_addr_n <= rd_addr_r;
        wr_addr_n <= wr_addr_r;
        empty_n <= empty_r;
        full_n <= full_r;
        case (op) is
            when "00" => -- nothing
            when "01" => -- read
                if (empty_r /= '1') then
                    rd_addr_n <= rd_addr_succ;
                    full_n <= '0';
                    if (rd_addr_succ = wr_addr_r) then
                        empty_n <= '1';
                    end if;
                end if;
            when "10" => -- write
                if (full_r /= '1') then
                    wr_addr_n <= wr_addr_succ;
                    empty_n <= '0';
                    if (wr_addr_succ = rd_addr_r) then
                        full_n <= '1';
                    end if; 
                end if;
            when others => -- write and read
                rd_addr_n <= rd_addr_succ;
                wr_addr_n <= wr_addr_succ;
        end case; 
    end process control_logic;
    
    empty_o <= empty_r;
    full_o <= full_r;

end arch;

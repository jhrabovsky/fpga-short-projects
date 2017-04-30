
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity uart_tx is  
    Generic (
        DBITS: integer := 8;
        SB_TICKS: integer := 16);
    
    Port (
        clk, rst: in std_logic;
        tick_i: in std_logic;
        tx_o: out std_logic;
        start_i: in std_logic;
        data_i: in std_logic_vector(DBITS-1 downto 0);
        done_o: out std_logic
    );
end uart_tx;

architecture arch of uart_tx is
type state_t is (idle, start, data, stop);

signal state_r, state_n: state_t;
signal dbits_sent_r, dbits_sent_n: unsigned(2 downto 0);
signal ticks_r, ticks_n: unsigned(3 downto 0);
signal data_r, data_n: std_logic_vector(DBITS-1 downto 0);
signal tx_r, tx_n: std_logic;

begin
    reg_update: process(clk, rst) is
    begin
        if (rst = '1') then
            state_r <= idle;
            dbits_sent_r <= (others=>'0');
            ticks_r <= (others=>'0');
            data_r <= (others=>'0');
            tx_r <= '1';
        elsif (rising_edge(clk)) then
            state_r <= state_n;
            dbits_sent_r <= dbits_sent_n;
            ticks_r <= ticks_n;
            data_r <= data_n;
            tx_r <= tx_n;
        end if;
    end process reg_update;

    sending_logic: process(state_r, ticks_r, data_r, dbits_sent_r, start_i, data_i, tick_i, tx_r) is
    begin
        state_n <= state_r;
        dbits_sent_n <= dbits_sent_r;
        ticks_n <= ticks_r;
        data_n <= data_r;
        tx_n <= tx_r;
        done_o <= '0';
        
        case (state_r) is
            when idle =>
                tx_n <= '1';
                if (start_i = '1') then
                    state_n <= start;
                    data_n <= data_i;
                    ticks_n <= (others=>'0');                                       
                end if;
            when start =>
                tx_n <= '0'; 
                if (tick_i = '1') then
                    if (ticks_r = 15) then
                        state_n <= data;
                        ticks_n <= (others=>'0');
                        dbits_sent_n <= (others=>'0');
                    else
                        ticks_n <= ticks_r + 1;
                    end if;
                end if;
            when data =>
                tx_n <= data_r(0);
                if (tick_i = '1') then
                    if (ticks_r = 15) then
                        ticks_n <= (others=>'0');
                        data_n <= '0' & data_r(DBITS-1 downto 1);                      
                        if (dbits_sent_r = (DBITS-1)) then
                            state_n <= stop;
                        else
                            dbits_sent_n <= dbits_sent_r + 1;
                        end if;
                    else
                        ticks_n <= ticks_r + 1;
                    end if;
                end if;
            when stop =>
                tx_n <= '1';
                if (tick_i = '1') then
                    if (ticks_r = SB_TICKS-1) then
                        state_n <= idle;
                        done_o <= '1';
                    else
                        ticks_n <= ticks_r + 1;
                    end if;
                end if;
        end case;
    end process sending_logic;
    
    tx_o <= tx_r;
end arch;

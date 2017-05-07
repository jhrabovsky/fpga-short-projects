
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx is
    Generic (
        DATA_BITS: integer := 8; 
        STOP_TICKS: integer := 16 -- 1 STOP bit - in number of ticks because of not integer count of bits possible for STOP
    );
    
    Port (
        clk, rst: in STD_LOGIC;
        rx_i: in STD_LOGIC;
        tick_i: in STD_LOGIC;
        data_o: out STD_LOGIC_VECTOR(DATA_BITS-1 downto 0);
        done_o: out STD_LOGIC
    );
end uart_rx;

architecture arch of uart_rx is
type state_t is (idle, start, data, stop);
signal state_r, state_n: state_t;
signal waitS_r, waitS_n: unsigned(3 downto 0);
signal dbits_rx_r, dbits_rx_n: unsigned(2 downto 0);
signal data_r, data_n: STD_LOGIC_VECTOR(DATA_BITS-1 downto 0);

begin
    regs_update: process(clk, rst) is
    begin
        if (rst = '1') then
            state_r <= idle;
            data_r <= (others => '0');
            waitS_r <= (others => '0');
            dbits_rx_r <= (others => '0');
        elsif (rising_edge(clk)) then
            state_r <= state_n;
            data_r <= data_n;
            waitS_r <= waitS_n;
            dbits_rx_r <= dbits_rx_n;
        end if;
    end process regs_update;

    control_logic: process(state_r, rx_i, tick_i, waitS_r, dbits_rx_r, data_r) is
    begin
        -- setting default values for signals/outputs
        done_o <= '0';
        data_n <= data_r;
        state_n <= state_r;
        waitS_n <= waitS_r;
        dbits_rx_n <= dbits_rx_r;
        
        case (state_r) is
            when idle => 
                if (rx_i = '0') then
                    waitS_n <= (others => '0');
                    state_n <= start;
                end if;
            when start =>
                if (tick_i = '1') then
                    if (waitS_r = 7) then
                        waitS_n <= (others => '0');
                        dbits_rx_n <= (others => '0');
                        state_n <= data;
                    else
                        waitS_n <= waitS_r + 1;
                    end if;
                end if;
            when data => 
                if (tick_i = '1') then
                    if (waitS_r = 15) then
                        waitS_n <= (others => '0');
                        data_n <= rx_i & data_r(DATA_BITS-1 downto 1);
                        if (dbits_rx_r = DATA_BITS-1) then
                            state_n <= stop;
                        else
                            dbits_rx_n <= dbits_rx_r + 1;
                        end if;                        
                    else
                        waitS_n <= waitS_r + 1;
                    end if;
                end if;
            when stop =>
                if (tick_i = '1') then
                    if (waitS_r = (STOP_TICKS-1)) then
                        done_o <= '1';
                        state_n <= idle;
                    else
                        waitS_n <= waitS_r + 1; 
                    end if;
                end if;                
       end case;         
    end process control_logic;
    
    data_o <= data_r;
end arch;

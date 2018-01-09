
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_tb is
end top_tb;

architecture Behavioral of top_tb is

component uart_top is
    Port (
        UART_TXD_IN: in std_logic; -- PC->FPGA
        UART_RXD_OUT: out std_logic; -- FPGA->PC
        CLK100MHZ: in std_logic;
        RST: in std_logic;
        LED: out std_logic_vector(9 downto 0);
        BTN: in std_logic;
        AN: out std_logic_vector(7 downto 0)
    );    
end component uart_top;
 
constant T : time := 5ns;

signal clk, rst : std_logic;
signal tx, rx, btn : std_logic;
signal data : std_logic_vector(9 downto 0);
signal an : std_logic_vector(7 downto 0);

begin
    uut : uart_top
        port map (
            UART_TXD_IN => rx,
            UART_RXD_OUT => tx,
            CLK100MHZ => clk,
            RST => rst,
            LED => data,
            BTN => btn,
            AN => an
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
        btn <= '0';
        rx <= '1';
        wait for 2*T;
        
        rst <= '0';
        wait for T;
        
        loop
            btn <= '1';
            wait for 10*T;
            btn <= '0';
            wait for 30*T;
        end loop;      
          
    end process stimuli;    



end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_tb is
end top_tb;

architecture Behavioral of top_tb is

component top is
    Generic (
        N : natural;
        ADDR_LEN : natural;
        DATA_LEN : natural
    );
    
    Port (
        clk : in std_logic;
        rst : in std_logic;
        ce : in std_logic;
        addrs : in std_logic_vector(N * ADDR_LEN - 1 downto 0);
        datas : out std_logic_vector(N * DATA_LEN - 1 downto 0)
    );
end component;

constant T : time := 5ns;
signal clk, rst : std_logic;

signal ce : std_logic;
signal datas : std_logic_vector(N * DATA_LEN - 1 downto 0);
signal addrs : std_logic_vector(N * ADDR_LEN - 1 downto 0) := (others => '0');

begin

    uut : top
        generic map (
            N => 2,
            ADDR_LEN => 4,
            DATA_LEN => 8
        )
        port map (
            clk => clk,
            rst => rst,
            ce => ce,
            addrs => addrs,
            datas => datas
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
        ce <= '0';
        rst <= '1';
        wait for T;
        rst <= '0';
        wait for 2*T;
        
        ce <= '1';
        wait;   
    end process stimuli;
     
end Behavioral;

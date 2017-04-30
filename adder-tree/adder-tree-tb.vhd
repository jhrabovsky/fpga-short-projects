
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity adder_tree_tb is
end adder_tree_tb;

architecture Behavioral of adder_tree_tb is

component adder_tree is
	Generic (
		NO_INPUTS : natural;
		DATA_WIDTH : natural
	);

	Port (
		din : in std_logic_vector(DATA_WIDTH * NO_INPUTS - 1 downto 0);
        dout : out std_logic_vector(DATA_WIDTH - 1 downto 0);
        clk : in std_logic;
        ce : in std_logic;
        rst : in std_logic
	); 
end component;

constant DATA_WIDTH : natural := 5;
constant NO_INPUTS : natural := 7;


signal din : std_logic_vector(DATA_WIDTH * NO_INPUTS - 1 downto 0);
signal dout : std_logic_vector(DATA_WIDTH - 1 downto 0); 

signal clk, ce, rst : std_logic;
constant T : time := 10ns;

begin

    din_gen : for I in 1 to NO_INPUTS generate
        din(DATA_WIDTH * I - 1 downto DATA_WIDTH * (I-1)) <= std_logic_vector(to_signed(I-2, DATA_WIDTH));
    end generate; 
    
    uut : adder_tree
        generic map (
            NO_INPUTS => NO_INPUTS,
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            din => din,
            dout => dout,
            clk => clk,
            ce => ce,
            rst => rst
        );
 
    clk_gen : process is
    begin
        clk <= '0';
        wait for T/2;
        clk <= '1';
        wait for T/2;
    end process clk_gen;
    
    ce <= '1';
    
    stimuli : process is
    begin
        rst <= '1';
        wait for T;
        rst <= '0';
        wait for T;
        
        wait;
    end process stimuli;
             
end Behavioral;

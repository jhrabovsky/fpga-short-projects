library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;

entity fc_layer_tb is
end fc_layer_tb;

architecture Behavioral of fc_layer_tb is

component fc_layer is
	generic (
		NO_INPUTS : natural;
		DATA_WIDTH : natural;
		COEF_WIDTH : natural;
		RESULT_WIDTH : natural
	);
	
	port (
		din : in std_logic_vector(NO_INPUTS * DATA_WIDTH - 1 downto 0);
		w : in std_logic_vector(NO_INPUTS * COEF_WIDTH - 1 downto 0);
		dout : out std_logic_vector(RESULT_WIDTH - 1 downto 0);
		clk : in std_logic;
		rst : in std_logic;
		ce : in std_logic
	);
end component;

constant T : time := 10ns;
signal clk, rst, ce : std_logic;


constant NO_INPUTS : natural := 6;
constant DATA_WIDTH : natural := 4;
constant COEF_WIDTH : natural := 3;
constant RESULT_WIDTH : natural := 7;

signal w : std_logic_vector(NO_INPUTS * COEF_WIDTH - 1 downto 0);
signal x : std_logic_vector(NO_INPUTS * DATA_WIDTH - 1 downto 0);
signal y : std_logic_vector(RESULT_WIDTH - 1 downto 0);

begin
    uut : fc_layer
        generic map (
            NO_INPUTS => NO_INPUTS,
            DATA_WIDTH => DATA_WIDTH,
            COEF_WIDTH => COEF_WIDTH,
            RESULT_WIDTH => RESULT_WIDTH
        )
        port map (
            din => x,
            w => w,
            dout => y,
            clk => clk,
            rst => rst,
            ce => ce
        );

    x <= std_logic_vector(to_signed(3, DATA_WIDTH)) &
         std_logic_vector(to_signed(1, DATA_WIDTH)) &
         std_logic_vector(to_signed(-1, DATA_WIDTH)) &
         std_logic_vector(to_signed(1, DATA_WIDTH)) &
         std_logic_vector(to_signed(2, DATA_WIDTH)) &
         std_logic_vector(to_signed(2, DATA_WIDTH));
    
    w <= std_logic_vector(to_signed(1, COEF_WIDTH)) &
         std_logic_vector(to_signed(-2, COEF_WIDTH)) &
         std_logic_vector(to_signed(3, COEF_WIDTH)) &
         std_logic_vector(to_signed(3, COEF_WIDTH)) &
         std_logic_vector(to_signed(-2, COEF_WIDTH)) &
         std_logic_vector(to_signed(1, COEF_WIDTH));
         
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
        wait for T;
        
        rst <= '0';
        wait for T;
        
        ce <= '1';
        wait;
    end process stimuli;      
end Behavioral;

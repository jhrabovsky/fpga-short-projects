library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;
    
entity fc_layer is
	generic (
		NO_INPUTS : natural := 6;
		DATA_WIDTH : natural := 8;
		COEF_WIDTH : natural := 5;
		RESULT_WIDTH : natural := 12
	);
	
	port (
		din : in std_logic_vector(NO_INPUTS * DATA_WIDTH - 1 downto 0);
		w : in std_logic_vector(NO_INPUTS * COEF_WIDTH - 1 downto 0);
		dout : out std_logic_vector(RESULT_WIDTH - 1 downto 0);
		clk : in std_logic;
		rst : in std_logic;
		ce : in std_logic
	);
end fc_layer;

architecture RTL of fc_layer is

------------------------------
--			COMPONENTS		--
------------------------------

component adder_tree is
	Generic (
		NO_INPUTS : natural;
		DATA_WIDTH : natural
	);

	Port (
		din : in std_logic_vector(NO_INPUTS * DATA_WIDTH - 1 downto 0);
        dout : out std_logic_vector(DATA_WIDTH - 1 downto 0);
        clk : in std_logic;
        ce : in std_logic;
        rst : in std_logic
	); 
end component;

------------------------------
--			CONSTANTS		--
------------------------------

constant MULT_RES_WIDTH : natural := DATA_WIDTH + COEF_WIDTH;

signal data_from_mult_to_adder : std_logic_vector(NO_INPUTS * MULT_RES_WIDTH - 1 downto 0);
signal res_from_adder : std_logic_vector(MULT_RES_WIDTH - 1 downto 0);

begin

	mult_gen : for I in 0 to NO_INPUTS - 1 generate
		data_from_mult_to_adder((I+1) * MULT_RES_WIDTH - 1 downto I * MULT_RES_WIDTH) <= std_logic_vector(
		  signed(din((I+1) * DATA_WIDTH - 1 downto I * DATA_WIDTH)) * signed(w((I+1) * COEF_WIDTH - 1 downto I * COEF_WIDTH))
		);
	end generate;

	adder_tree_inst : adder_tree
		generic map (
			NO_INPUTS => NO_INPUTS,
			DATA_WIDTH => MULT_RES_WIDTH
		)
		port map (
			din => data_from_mult_to_adder,
			dout => res_from_adder,
			clk => clk,
			ce => ce,
			rst => rst
		);

	dout <= res_from_adder(MULT_RES_WIDTH - 1 downto MULT_RES_WIDTH - RESULT_WIDTH);
	
end RTL;

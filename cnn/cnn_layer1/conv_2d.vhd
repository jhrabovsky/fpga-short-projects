
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity conv_2d is
    Generic(
        INPUT_ROW_LENGTH : integer := 32; -- row length in image
        KERNEL_SIZE : integer := 5;  -- kernel size
        DATA_WIDTH : natural := 9;
        DATA_FRAC_LEN : natural := 0;
        COEF_WIDTH : natural := 8;
        COEF_FRAC_LEN : natural := 7;
        RESULT_WIDTH : natural := 9;
        RESULT_FRAC_LEN : natural := 0
    );
    
    Port (
        din : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        w : in std_logic_vector(COEF_WIDTH * (KERNEL_SIZE**2) - 1 downto 0);
        dout : out std_logic_vector(RESULT_WIDTH - 1 downto 0);
        clk : in std_logic;
        ce : in std_logic;
        coef_load : in std_logic;
        rst : in std_logic     
    );
end conv_2d;

architecture Behavioral of conv_2d is

---------------------------------------------
--               COMPONENTS                --
---------------------------------------------

component se_chain is
    Generic (
        KERNEL_SIZE : integer; -- Number of elements (SE)
        DATA_WIDTH : natural;
        DATA_FRAC_LEN : natural;
        COEF_WIDTH : natural;
        COEF_FRAC_LEN : natural;
        RESULT_WIDTH : natural;
        RESULT_FRAC_LEN : natural     
    );
    
    Port (
        din : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        w : in std_logic_vector(COEF_WIDTH * (KERNEL_SIZE**2) - 1 downto 0);
        dp : out std_logic_vector(RESULT_WIDTH * KERNEL_SIZE - 1 downto 0);
        clk : in std_logic;
        ce : in std_logic;
        coef_load : in std_logic;
        rst : in std_logic             
    );
end component;

component delay_buffer is
    Generic (
        LENGTH : natural;
        DATA_WIDTH: natural
    );
    
    Port ( 
        din : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        dout : out std_logic_vector(DATA_WIDTH - 1 downto 0);
        clk, ce : in std_logic 
    );
end component;

component adder is
    Generic (
        DATA_WIDTH : integer
    );
    
    Port (
        din_a : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        din_b : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        dout : out std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
end component;

constant BASE_DELAY_LENGTH : integer := INPUT_ROW_LENGTH - 2*KERNEL_SIZE + 1;

signal dp_from_se : std_logic_vector(RESULT_WIDTH * KERNEL_SIZE - 1 downto 0);
signal from_buffer_to_adder : std_logic_vector(RESULT_WIDTH * (KERNEL_SIZE - 1) - 1 downto 0);
signal from_adder_to_buffer : std_logic_vector(RESULT_WIDTH * (KERNEL_SIZE - 1) - 1 downto 0);

signal bias : std_logic_vector(RESULT_WIDTH - 1 downto 0); 
signal dout_reg, dout_next : std_logic_vector(RESULT_WIDTH - 1 downto 0);

signal from_adder_to_adder : std_logic_vector(RESULT_WIDTH * (KERNEL_SIZE - 1) - 1 downto 0);

begin

---------------------------------------------
--            COMPONENT INSTANCES          --
---------------------------------------------
    
    se_chain_inst : se_chain
        generic map (
            KERNEL_SIZE => KERNEL_SIZE,
            DATA_WIDTH => DATA_WIDTH,
            DATA_FRAC_LEN => DATA_FRAC_LEN,
            COEF_WIDTH => COEF_WIDTH,
            COEF_FRAC_LEN => COEF_FRAC_LEN,
            RESULT_WIDTH => RESULT_WIDTH,
            RESULT_FRAC_LEN => RESULT_FRAC_LEN
        ) 
        port map (
            din => din,
            w => w,
            dp => dp_from_se,
            clk => clk,
            ce => ce,
            coef_load => coef_load,
            rst => rst
        );
    
---------------------------------------------
--            POSITIVE DELAY               --
---------------------------------------------

    gen_positive_delay : if (BASE_DELAY_LENGTH > 0) generate

        gen_delay_buffers: for I in (KERNEL_SIZE - 2) downto 0 generate
            delay_buffer_inst : delay_buffer 
                generic map (
                    LENGTH => BASE_DELAY_LENGTH, 
                    DATA_WIDTH => RESULT_WIDTH
                ) 
                port map (
                    din => from_adder_to_buffer(RESULT_WIDTH * (I+1) - 1 downto RESULT_WIDTH * I), 
                    dout => from_buffer_to_adder(RESULT_WIDTH * (I+1) - 1 downto RESULT_WIDTH * I), 
                    clk => clk, 
                    ce => ce
                );
        end generate gen_delay_buffers;
        
        gen_adders: for I in (KERNEL_SIZE - 1) downto 0 generate
            gen_adder_first : if (I = KERNEL_SIZE - 1) generate
                -- TODO: doriesit pripocitavanie biasu => 1 bias: (A) per pixel vystupnej mapy, (B) per vystupnu mapu.
                adder_first : adder
                    generic map (
                        DATA_WIDTH => RESULT_WIDTH
                    )
                    port map (
                        din_a => dp_from_se(RESULT_WIDTH * (I+1) - 1 downto RESULT_WIDTH * I),
                        din_b => bias,
                        dout => from_adder_to_buffer(RESULT_WIDTH * I - 1 downto RESULT_WIDTH * (I-1))
                    );
            end generate;

            gen_adder_i : if (I < KERNEL_SIZE - 1) and (I > 0) generate
                adder_i : adder
                    generic map (
                        DATA_WIDTH => RESULT_WIDTH
                    )
                    port map (
                        din_a => from_buffer_to_adder(RESULT_WIDTH * (I+1) - 1 downto RESULT_WIDTH * I),
                        din_b => dp_from_se(RESULT_WIDTH * (I+1) - 1 downto RESULT_WIDTH * I),
                        dout => from_adder_to_buffer(RESULT_WIDTH * I - 1 downto RESULT_WIDTH * (I-1))
                    );
            end generate;
        
            gen_adder_last : if (I = 0) generate
                adder_last : adder
                generic map (
                    DATA_WIDTH => RESULT_WIDTH
                )
                port map (
                    din_a => from_buffer_to_adder(RESULT_WIDTH - 1 downto 0),
                    din_b => dp_from_se(RESULT_WIDTH - 1 downto 0),
                    dout => dout_next
                );                       
            end generate;
        end generate gen_adders;
    
    end generate gen_positive_delay;

---------------------------------------------
--            NEGATIVE DELAY               --
---------------------------------------------

    gen_negative_delay : if (BASE_DELAY_LENGTH < 0) generate
        
        gen_delay_buffers: for I in (KERNEL_SIZE - 2) downto 0 generate
            delay_buffer_inst : delay_buffer 
                generic map (
                    LENGTH => -BASE_DELAY_LENGTH, 
                    DATA_WIDTH => RESULT_WIDTH
                ) 
                port map (
                    din => from_adder_to_buffer(RESULT_WIDTH * (I+1) - 1 downto RESULT_WIDTH * I), 
                    dout => from_buffer_to_adder(RESULT_WIDTH * (I+1) - 1 downto RESULT_WIDTH * I), 
                    clk => clk, 
                    ce => ce
                );
        end generate gen_delay_buffers;
        
        gen_adders: for I in (KERNEL_SIZE - 1) downto 0 generate
            gen_adder_first : if (I = KERNEL_SIZE - 1) generate
                -- TODO: doriesit pripocitavanie biasu    
                adder_first : adder
                    generic map (
                        DATA_WIDTH => RESULT_WIDTH
                    )
                    port map (
                        din_a => bias,
                        din_b => dp_from_se(RESULT_WIDTH * (KERNEL_SIZE - I) - 1 downto RESULT_WIDTH * (KERNEL_SIZE - I - 1)),
                        dout => from_adder_to_buffer(RESULT_WIDTH * I - 1 downto RESULT_WIDTH * (I-1))
                    );            
            end generate;

            gen_adder_i : if (I < KERNEL_SIZE - 1) and (I > 0) generate
                adder_i : adder
                    generic map (
                        DATA_WIDTH => RESULT_WIDTH
                    )
                    port map (
                        din_a => from_buffer_to_adder(RESULT_WIDTH * (I+1) - 1 downto RESULT_WIDTH * I),
                        din_b => dp_from_se(RESULT_WIDTH * (KERNEL_SIZE - I) - 1 downto RESULT_WIDTH * (KERNEL_SIZE - I - 1)),
                        dout => from_adder_to_buffer(RESULT_WIDTH * I - 1 downto RESULT_WIDTH * (I-1))
                    );                        
            end generate;
        
            gen_adder_last : if (I = 0) generate
                adder_last : adder
                generic map (
                    DATA_WIDTH => RESULT_WIDTH
                )
                port map (
                    din_a => from_buffer_to_adder(RESULT_WIDTH - 1 downto 0),
                    din_b => dp_from_se(RESULT_WIDTH * (KERNEL_SIZE) - 1 downto RESULT_WIDTH * (KERNEL_SIZE - 1)),
                    dout => dout_next
                ); 
            end generate;
        end generate gen_adders;
  
    end generate gen_negative_delay;

---------------------------------------------
--            ZERO DELAY                   --
---------------------------------------------

    gen_zero_delay : if (BASE_DELAY_LENGTH = 0) generate
        
        gen_adders: for I in (KERNEL_SIZE - 1) downto 0 generate
            gen_adder_first : if (I = KERNEL_SIZE - 1) generate
                -- TODO: doriesit pripocitavanie biasu    
                adder_first : adder
                    generic map (
                        DATA_WIDTH => RESULT_WIDTH
                    )
                    port map (
                        din_a => dp_from_se(RESULT_WIDTH * (I+1) - 1 downto RESULT_WIDTH * I),
                        din_b => bias,
                        dout => from_adder_to_adder(RESULT_WIDTH * I - 1 downto RESULT_WIDTH * (I-1))
                    );            
            end generate;

            gen_adder_i : if (I < KERNEL_SIZE - 1) and (I > 0) generate
                adder_i : adder
                    generic map (
                        DATA_WIDTH => RESULT_WIDTH
                    )
                    port map (
                        din_a => from_adder_to_adder(RESULT_WIDTH * (I+1) - 1 downto RESULT_WIDTH * I),
                        din_b => dp_from_se(RESULT_WIDTH * (I+1) - 1 downto RESULT_WIDTH * I),
                        dout => from_adder_to_adder(RESULT_WIDTH * I - 1 downto RESULT_WIDTH * (I-1))
                    );                        
            end generate;
        
            gen_adder_last : if (I = 0) generate
                adder_last : adder
                generic map (
                    DATA_WIDTH => RESULT_WIDTH
                )
                port map (
                    din_a => from_adder_to_adder(RESULT_WIDTH - 1 downto 0),
                    din_b => dp_from_se(RESULT_WIDTH - 1 downto 0),
                    dout => dout_next
                );                       
            end generate;
        end generate gen_adders;

    end generate gen_zero_delay;

---------------------------------------------
--            REGISTERS                    --
---------------------------------------------

	registers: process(clk) is
	begin
		if (rising_edge(clk)) then
			if (ce = '1') then
				dout_reg <= dout_next;
			end if;
		end if;
	end process registers;

    dout <= dout_reg;
    bias <= (others => '0');  

end Behavioral;

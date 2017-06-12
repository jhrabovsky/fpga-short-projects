
library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use ieee.numeric_std.all;

use work.misc_pkg.all;

entity fsm is
    Generic (
        NO_INPUT_MAPS : natural := 1;
        INPUT_ROW_LENGTH : integer := 32;
        KERNEL_SIZE : integer := 5
    );
    
    Port ( 
        clk : in std_logic;
		rst : in std_logic;
		run : in std_logic;
		valid : out std_logic
	);
end fsm;

architecture Behavioral of fsm is

constant STARTUP_DELAY_PART1 : integer := KERNEL_SIZE * (2 * KERNEL_SIZE - 1) + 2;
constant STARTUP_DELAY_PART2 : integer := (KERNEL_SIZE - 1) * (INPUT_ROW_LENGTH - 2 * KERNEL_SIZE + 1);
constant STARTUP_DELAY_TREE : natural := log2c(NO_INPUT_MAPS); 
constant STARTUP_DELAY : integer := STARTUP_DELAY_PART1 + STARTUP_DELAY_PART2 + STARTUP_DELAY_TREE + 1; -- za conv_2d vlozeny REG

constant INVALID_LINE_PART : integer := KERNEL_SIZE - 1;
constant VALID_LINE_PART : integer := INPUT_ROW_LENGTH - KERNEL_SIZE + 1;

component counter_down_generic is
	Generic (
		THRESHOLD_WIDTH : natural
	);
	
    Port ( 
        clk : in std_logic;
        ce : in std_logic;
        clear : in std_logic;
		set : in std_logic;
		threshold : in std_logic_vector(THRESHOLD_WIDTH - 1 downto 0);
        tc : out std_logic -- terminal count
    );
end component;

type state_type is (init, startup, compute_valid, compute_invalid, overlap_image);
signal state_reg : state_type := init;
signal state_next : state_type;

signal valid_out_tmp : std_logic;

----------------------------        
--      TIMER PARAMS      --
----------------------------

constant TIM_THRESHOLD_WIDTH : natural := 8;
signal tim_clear, tim_set, tim_alert, tim_ce : std_logic;
signal tim_clear_tmp, tim_set_tmp: std_logic;

signal tim_threshold : std_logic_vector(TIM_THRESHOLD_WIDTH - 1 downto 0);

------------------------------        
--      LINE-COUNTER PARAMS --
------------------------------

constant COUNT_THRESHOLD_WIDTH : natural := 8; -- mozem zlepsit, ked pouzijem log2c na (K-1)
signal count_clear, count_set, count_alert, count_ce : std_logic;
signal count_clear_tmp, count_set_tmp, count_ce_tmp : std_logic;

signal count_threshold : std_logic_vector(COUNT_THRESHOLD_WIDTH - 1 downto 0);
constant COUNT_VALID_LINES : natural := INPUT_ROW_LENGTH - KERNEL_SIZE + 1; 
constant COUNT_TRANSIT_PIXELS : natural := (KERNEL_SIZE - 1) * INPUT_ROW_LENGTH - 1; -- 1 CLK stojim e+ste v stave compute_valid, aby som identifikoval prechod na stav overlap_image;

begin

	timer : counter_down_generic
		generic map (
			THRESHOLD_WIDTH => TIM_THRESHOLD_WIDTH
		)
		port map (
			clk => clk,
			ce => tim_ce,
			clear => tim_clear,
			set => tim_set,
			threshold => tim_threshold,
			tc => tim_alert
		);
				
	line_counter : counter_down_generic
	   generic map (
                THRESHOLD_WIDTH => COUNT_THRESHOLD_WIDTH
            )
            port map (
                clk => clk,
                ce => count_ce,
                clear => count_clear,
                set => count_set,
                threshold => count_threshold,
                tc => count_alert
            );
	               
    registers: process (clk) is
    begin
        if (rising_edge(clk)) then
            if (rst = '1') then
                state_reg <= init;
            elsif (run = '1') then
				state_reg <= state_next;
			end if;
        end if;
    end process registers;            
                
    control_logic: process (state_reg, tim_alert, count_alert) is
    begin
        state_next <= state_reg;
        valid_out_tmp <= '0';
		
		tim_clear_tmp <= '0';
		tim_set_tmp <= '0';
		tim_threshold <= (others => '0');

        count_clear_tmp <= '0';
        count_set_tmp <= '0';
		count_ce_tmp <= '0';
		count_threshold <= (others => '0');
		
        case state_reg is
            when init =>
                tim_threshold <= std_logic_vector(to_unsigned(STARTUP_DELAY - 1, TIM_THRESHOLD_WIDTH));
		      	tim_set_tmp <= '1';
                state_next <= startup;
                
            when startup =>
                if (tim_alert = '1') then
                    tim_threshold <= std_logic_vector(to_unsigned(VALID_LINE_PART - 1, TIM_THRESHOLD_WIDTH));
					tim_set_tmp <= '1';
                    count_threshold <= std_logic_vector(to_unsigned(COUNT_VALID_LINES, COUNT_THRESHOLD_WIDTH));
                    count_set_tmp <= '1';
                    state_next <= compute_valid;    
                end if;
                
            when compute_valid =>                
                valid_out_tmp <= '1';                       
                if (tim_alert = '1') then
                    tim_threshold <= std_logic_vector(to_unsigned(INVALID_LINE_PART - 1, TIM_THRESHOLD_WIDTH));
					tim_set_tmp <= '1';
                    state_next <= compute_invalid;
                end if;
                
                if (count_alert = '1') then
                    valid_out_tmp <= '0';
                    tim_threshold <= std_logic_vector(to_unsigned(COUNT_TRANSIT_PIXELS - 1, TIM_THRESHOLD_WIDTH));
                    tim_set_tmp <= '1';
                    state_next <= overlap_image;
                    count_clear_tmp <= '1';
                end if;
            
            when compute_invalid =>
                if (tim_alert = '1') then -- prechod na dalsi riadok
                    tim_threshold <= std_logic_vector(to_unsigned(VALID_LINE_PART - 1, TIM_THRESHOLD_WIDTH));
					tim_set_tmp <= '1';
                    state_next <= compute_valid;
                    count_ce_tmp <= '1';                                                     
                end if;
            
            when overlap_image =>
                if (tim_alert = '1') then
                    tim_threshold <= std_logic_vector(to_unsigned(VALID_LINE_PART - 1, TIM_THRESHOLD_WIDTH));
                    tim_set_tmp <= '1';
                    state_next <= compute_valid;
                end if;
                                          
            when others =>
                state_next <= init;  
                  
        end case;     
    end process control_logic;
    
    tim_ce <= run;
    tim_set <= tim_set_tmp and run;
    tim_clear <= tim_clear_tmp and run;
    
    count_ce <= count_ce_tmp and run;
    count_set <= count_set_tmp and run;
    count_clear <= count_clear_tmp and run;
    
    valid <= valid_out_tmp and run;

end Behavioral;

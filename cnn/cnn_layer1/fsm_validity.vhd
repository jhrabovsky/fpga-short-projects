
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

constant STARTUP_DELAY_PART1 : integer := KERNEL_SIZE * (2 * KERNEL_SIZE - 1) + 2; -- +2 = 1xOUTPUT-REG & 1xREG-in-the-last-DSP(between-mult&add) 
constant STARTUP_DELAY_PART2 : integer := (KERNEL_SIZE - 1) * (INPUT_ROW_LENGTH - 2 * KERNEL_SIZE + 1) + 1; -- +1 = OUTPUT-REG
constant STARTUP_DELAY_TREE : natural := log2c(NO_INPUT_MAPS); 
constant STARTUP_DELAY : integer := STARTUP_DELAY_PART1 + STARTUP_DELAY_PART2 + STARTUP_DELAY_TREE; 

constant NO_INVALID_PIXELS_PER_LINE : integer := KERNEL_SIZE - 1; -- number of invalid pixels per line (vertical border crossing)
constant NO_VALID_PIXELS_PER_LINE : integer := INPUT_ROW_LENGTH - KERNEL_SIZE + 1; -- number of valid pixels per line (inside image)

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

type state_type is (init, start_up, inside_image, vertical_border, horizontal_border);
signal state_reg : state_type := init;
signal state_next : state_type;

signal valid_out_tmp : std_logic;

-------------------------------            
--      PIXEL-COUNTER PARAMS --
-------------------------------

constant PIXEL_COUNTER_THRESHOLD_WIDTH : natural := 8; -- TODO: compute threshold via log2c();
signal pixel_counter_clear, pixel_counter_set, pixel_counter_alert, pixel_counter_ce : std_logic;
signal pixel_counter_clear_tmp, pixel_counter_set_tmp: std_logic;

signal pixel_counter_threshold : std_logic_vector(PIXEL_COUNTER_THRESHOLD_WIDTH - 1 downto 0);

------------------------------        
--      LINE-COUNTER PARAMS --
------------------------------

constant LINE_COUNTER_THRESHOLD_WIDTH : natural := 8; -- TODO: compute threshold via log2c(); 
signal line_counter_clear, line_counter_set, line_counter_alert, line_counter_ce : std_logic;
signal line_counter_clear_tmp, line_counter_set_tmp, line_counter_ce_tmp : std_logic;

signal line_counter_threshold : std_logic_vector(LINE_COUNTER_THRESHOLD_WIDTH - 1 downto 0);

-- number of valid lines per input image
constant NO_VALID_LINES_PER_IMAGE : natural := INPUT_ROW_LENGTH - KERNEL_SIZE + 1; 
-- number of PIXELS per vertical border transition
constant NO_INVALID_PIXELS_PER_TRANSITION : natural := (KERNEL_SIZE - 1) * INPUT_ROW_LENGTH - 1;
-- the FSM waits for 1 CLK more in inside_image state in order to identify transition to horizontal_border

begin

	pixel_counterer : counter_down_generic
		generic map (
			THRESHOLD_WIDTH => PIXEL_COUNTER_THRESHOLD_WIDTH
		)
		port map (
			clk => clk,
			ce => pixel_counter_ce,
			clear => pixel_counter_clear,
			set => pixel_counter_set,
			threshold => pixel_counter_threshold,
			tc => pixel_counter_alert
		);
				
	line_counter : counter_down_generic
	   generic map (
                THRESHOLD_WIDTH => LINE_COUNTER_THRESHOLD_WIDTH
            )
            port map (
                clk => clk,
                ce => line_counter_ce,
                clear => line_counter_clear,
                set => line_counter_set,
                threshold => line_counter_threshold,
                tc => line_counter_alert
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
                
    control_logic: process (state_reg, pixel_counter_alert, line_counter_alert) is
    begin
        state_next <= state_reg;
        valid_out_tmp <= '0';
		
		pixel_counter_clear_tmp <= '0';
		pixel_counter_set_tmp <= '0';
		pixel_counter_threshold <= (others => '0');

        line_counter_clear_tmp <= '0';
        line_counter_set_tmp <= '0';
		line_counter_ce_tmp <= '0';
		line_counter_threshold <= (others => '0');
		
        case state_reg is
            when init =>
                pixel_counter_threshold <= std_logic_vector(to_unsigned(STARTUP_DELAY - 1, PIXEL_COUNTER_THRESHOLD_WIDTH));
		      	pixel_counter_set_tmp <= '1';
                state_next <= start_up;
                
            when start_up =>
                if (pixel_counter_alert = '1') then
                    pixel_counter_threshold <= std_logic_vector(to_unsigned(NO_VALID_PIXELS_PER_LINE - 1, PIXEL_COUNTER_THRESHOLD_WIDTH));
					pixel_counter_set_tmp <= '1';
                    line_counter_threshold <= std_logic_vector(to_unsigned(NO_VALID_LINES_PER_IMAGE, LINE_COUNTER_THRESHOLD_WIDTH));
                    line_counter_set_tmp <= '1';
                    state_next <= inside_image;    
                end if;
                
            when inside_image =>
                -- PRIORITY = 2
                valid_out_tmp <= '1';                       
                if (pixel_counter_alert = '1') then
                    pixel_counter_threshold <= std_logic_vector(to_unsigned(NO_INVALID_PIXELS_PER_LINE - 1, PIXEL_COUNTER_THRESHOLD_WIDTH));
					pixel_counter_set_tmp <= '1';
                    state_next <= vertical_border;
                end if;
                
                -- PRIORITY = 1
                if (line_counter_alert = '1') then
                    -- [?] WHY cannot I count one cycle less and set the invalidity when in the overlap_image state?
                     -- Because I count the lines with COUNT and so the 1 line earlier reaction is inappropriate.
                    valid_out_tmp <= '0';  
                    pixel_counter_threshold <= std_logic_vector(to_unsigned(NO_INVALID_PIXELS_PER_TRANSITION - 1, PIXEL_COUNTER_THRESHOLD_WIDTH));
                    pixel_counter_set_tmp <= '1';
                    state_next <= horizontal_border;
                    line_counter_clear_tmp <= '1';
                end if;
            
            when vertical_border =>
                if (pixel_counter_alert = '1') then -- transition to the next line
                    pixel_counter_threshold <= std_logic_vector(to_unsigned(NO_VALID_PIXELS_PER_LINE - 1, PIXEL_COUNTER_THRESHOLD_WIDTH));
					pixel_counter_set_tmp <= '1';
                    state_next <= inside_image;
                    line_counter_ce_tmp <= '1'; -- increment a value of the line counter because of the transition to the next line                                                     
                end if;
            
            when horizontal_border =>
                if (pixel_counter_alert = '1') then
                    pixel_counter_threshold <= std_logic_vector(to_unsigned(NO_VALID_PIXELS_PER_LINE - 1, PIXEL_COUNTER_THRESHOLD_WIDTH));
                    pixel_counter_set_tmp <= '1';
                    state_next <= inside_image;
                end if;
                                          
            when others =>
                state_next <= init;  
                  
        end case;     
    end process control_logic;
    
    pixel_counter_ce <= run;
    pixel_counter_set <= pixel_counter_set_tmp and run;
    pixel_counter_clear <= pixel_counter_clear_tmp and run;
    
    line_counter_ce <= line_counter_ce_tmp and run;
    line_counter_set <= line_counter_set_tmp and run;
    line_counter_clear <= line_counter_clear_tmp and run;
    
    valid <= valid_out_tmp and run;

end Behavioral;

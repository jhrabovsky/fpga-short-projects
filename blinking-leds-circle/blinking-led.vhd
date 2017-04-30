library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity blinking_led is
	port (
		clk: in std_logic;
		rst: in std_logic;
		cw: in std_logic;
		seg: out std_logic_vector(7 downto 0);
		an: out std_logic_vector(7 downto 0)
	);
end blinking_led;

architecture behavior of blinking_led is
signal count, count_next: unsigned(2 downto 0);
signal dir, dir_next: std_logic;

constant low_sq: std_logic_vector(7 downto 0) := "10100011";
constant high_sq: std_logic_vector(7 downto 0) := "10011100"; 

SIGNAL cw_dir: STD_LOGIC_VECTOR(1 downto 0);
begin
	reg_count: process (clk, rst, cw)
	begin
		if (rst = '1') then
			count <= "000";
			dir <= '1';
		elsif (rising_edge(clk)) then
			count <= count_next;
			dir <= dir_next;
		end if;
	end process reg_count;
	
	upd_count: process (count, dir)
	begin
		count_next <= count;
		dir_next <= dir;
		
		case (dir) is
			when '1' => 
				if (count >= 7) then
					dir_next <= '0';
				else
					count_next <= count + 1;
				end if;
			when '0' =>
				if (count <= 0) then
					dir_next <= '1';
				else
					count_next <= count - 1;
				end if;
			when others =>
				count_next <= "000";
				dir_next <= '1';	
		end case;
	end process upd_count;

    cw_dir <= cw & dir;
    
	with (cw_dir) select
		seg <= high_sq when "00" | "11",
			   low_sq when others;

	with (count) select
		an <= "11111110" when "111",
			  "11111101" when "110",
			  "11111011" when "101",
		      "11110111" when "100",
	          "11101111" when "011",
			  "11011111" when "010",
			  "10111111" when "001",
			  "01111111" when "000",
			  "11111111" when others;
		   
end behavior; 

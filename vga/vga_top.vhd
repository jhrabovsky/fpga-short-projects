
library ieee;
use ieee.std_logic_1164.all;

entity top is
   port (
      clk,reset: in std_logic;
      hsync, vsync: out  std_logic;
      rgb: out std_logic_vector(11 downto 0)
   );
end top;

architecture arch of top is
   
	component vga_sync is
		port(
			clk, reset: in std_logic;
			hsync, vsync: out std_logic;
			video_on, p_tick: out std_logic;
			pixel_x, pixel_y: out std_logic_vector (9 downto 0)
		);
	end component; 
   
	component bitmap_gen is
		port(
			video_on: in std_logic;
			pixel_x,pixel_y: in std_logic_vector(9 downto 0);
			graph_rgb: out std_logic_vector(11 downto 0)	-- (11 downto 8) -> red, (7 downto 4) -> green, (3 downto 0) -> blue
		);
	end component;
   
   signal pixel_x, pixel_y: std_logic_vector (9 downto 0);
   signal video_on, pixel_tick: std_logic;
   signal rgb_reg, rgb_next: std_logic_vector(11 downto 0);
   
begin
   -- instantiate VGA sync
   vga_sync_unit: vga_sync
		port map(
			clk => clk,
			reset => reset,
			video_on => video_on, p_tick => pixel_tick,
			hsync => hsync, vsync => vsync,
			pixel_x => pixel_x, pixel_y => pixel_y
		);
			   
   -- instantiate graphic generator
   bitmap_gen_unit: bitmap_gen
		port map (
			video_on => video_on,
            pixel_x => pixel_x, pixel_y => pixel_y,
            graph_rgb => rgb_next
		);
		
   -- rgb buffer
   process (clk)
   begin
      if (rising_edge(clk)) then
         if (pixel_tick = '1') then
            rgb_reg <= rgb_next;
         end if;
      end if;
   end process;
   
   rgb <= rgb_reg;
   
end arch;
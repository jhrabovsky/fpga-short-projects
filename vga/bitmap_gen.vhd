
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bitmap_gen is
   port(
      video_on: in std_logic;
      pixel_x,pixel_y: in std_logic_vector(9 downto 0);
      graph_rgb: out std_logic_vector(11 downto 0)	-- (11 downto 8) -> red, (7 downto 4) -> green, (3 downto 0) -> blue
   );
end bitmap_gen;

architecture Behavioral of bitmap_gen is

   -- x, y coordinates (0,0) to (639,479)
   signal pix_x, pix_y: unsigned(9 downto 0);
   constant MAX_X: integer:=640;
   constant MAX_Y: integer:=480;
   
   signal input_image_on : std_logic;
   signal input_image_rgb : std_logic_vector(3 downto 0);
   
   constant IMAGE_ROW_LENGTH : integer := 8;
   constant SCALE : integer := 32;
   constant IN_IMAGE_X_MIN : integer := 0;
   constant IN_IMAGE_X_MAX : integer := IN_IMAGE_X_MIN + IMAGE_ROW_LENGTH * SCALE - 1;
   
   constant IN_IMAGE_Y_MIN : integer := 0;
   constant IN_IMAGE_Y_MAX : integer := IN_IMAGE_Y_MIN + IMAGE_ROW_LENGTH * SCALE - 1;
   
   type IMAGE is array (0 to IMAGE_ROW_LENGTH-1, 0 to IMAGE_ROW_LENGTH-1) of integer;
   
   constant INPUT_MAP : IMAGE := ( (  0,  0,  0,255,255,  0,  0,  0),   
                                   (  0,  0,255,255,255,  0,  0,  0),
                                   (  0,255,255,255,255,  0,  0,  0),
                                   (255,255,  0,255,255,  0,  0,  0),
                                   (255,  0,  0,255,255,  0,  0,  0),
                                   (  0,  0,  0,255,255,  0,  0,  0),
                                   (255,255,255,255,255,255,255,255),
                                   (255,255,255,255,255,255,255,255));
    
    signal x_index, y_index : unsigned(2 downto 0);
    signal pixel : std_logic_vector(7 downto 0);
                                                                                    
begin
	-- prevod vst suradnic pixelu na unsigned => pre porovnavanie s integerom. 
   pix_x <= unsigned(pixel_x);
   pix_y <= unsigned(pixel_y);
   
   input_image_on <= '1' when (IN_IMAGE_X_MIN <= pix_x) and (IN_IMAGE_X_MAX >= pix_x) and (IN_IMAGE_Y_MIN <= pix_y) and (IN_IMAGE_Y_MAX >= pix_y) else
                     '0';
    
   x_index <= pix_x(7 downto 5); 
   y_index <= pix_y(7 downto 5);
   pixel <= std_logic_vector(to_unsigned(INPUT_MAP(to_integer(y_index), to_integer(x_index)), 8));
   
   input_image_rgb <= pixel(7 downto 4);
   
   ----------------------------------------------
   -- rgb multiplexing circuit
   ----------------------------------------------
   process(video_on, input_image_rgb, input_image_on)
   begin
      if video_on='0' then
          graph_rgb <= "000000000000"; --blank => mimo viditelny rozsah
      else
         if input_image_on = '1' then
            graph_rgb <= input_image_rgb & input_image_rgb & input_image_rgb;
         else
            graph_rgb <= "111111110000"; -- yellow background
         end if;
      end if;
   end process;
   
end Behavioral;

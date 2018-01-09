library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sseg_display is
    Generic ( 
        N: integer := 17;
        mask: in std_logic_vector(7 downto 0) -- specifies what 7seg displays should be ENABLED (1) and what DISABLED (0)
    );

    Port ( 
        hex1 : in STD_LOGIC_VECTOR (3 downto 0);
        hex2 : in STD_LOGIC_VECTOR (3 downto 0);
        hex3 : in STD_LOGIC_VECTOR (3 downto 0);
        hex4 : in STD_LOGIC_VECTOR (3 downto 0);
        hex5 : in STD_LOGIC_VECTOR (3 downto 0);
        hex6 : in STD_LOGIC_VECTOR (3 downto 0);
        hex7 : in STD_LOGIC_VECTOR (3 downto 0);
        hex8 : in STD_LOGIC_VECTOR (3 downto 0);
        clk, rst : in STD_LOGIC;
        sseg : out STD_LOGIC_VECTOR (7 downto 0);
        an : out STD_LOGIC_VECTOR (7 downto 0)
    );
end sseg_display;

architecture arch of sseg_display is

component hex_to_sseg is
    Port ( hex : in STD_LOGIC_VECTOR (3 downto 0);
           dp: in STD_LOGIC;
           sseg : out STD_LOGIC_VECTOR (7 downto 0)
    );
end component;
 
signal c_reg: unsigned(N+2 downto 0);
signal sel: unsigned(2 downto 0);
signal an_tmp: std_logic_vector(7 downto 0);
signal hex : std_logic_vector(3 downto 0);

begin
    syn_reg: process(clk, rst)
    begin
        if (rst = '1') then
            c_reg <= (others=>'0'); 
        elsif (rising_edge(clk)) then
            c_reg <= c_reg + 1;
        end if;
    end process syn_reg;
    
    hex_to_sseg_inst: hex_to_sseg port map (hex=>hex, dp=>'1', sseg=>sseg);
    sel <= c_reg(N+2 downto N);
    
    sseg_an_setup: process(sel, hex1, hex2, hex3, hex4, hex5, hex6, hex7, hex8) is
    begin
        case sel is
            when "000" =>
                hex <= hex1;
                an_tmp <= "11111110";
            when "001" =>
                hex <= hex2;
                an_tmp <= "11111101";
            when "010" =>
                hex <= hex3;
                an_tmp <= "11111011";
            when "011" =>
                hex <= hex4;
                an_tmp <= "11110111";
            when "100" =>
                hex <= hex5;
                an_tmp <= "11101111";
            when "101" =>
                hex <= hex6;
                an_tmp <= "11011111";
            when "110" =>
                hex <= hex7;
                an_tmp <= "10111111";
            when others => -- "111"
                hex <= hex8;
                an_tmp <= "01111111";
         end case;
    end process sseg_an_setup;
    
    an <= an_tmp or (not mask);
 
end arch;

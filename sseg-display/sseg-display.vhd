----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02.03.2016 20:27:06
-- Design Name: 
-- Module Name: sseg_display - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sseg_display is
    Generic (N: unsigned(3 downto 0) := "1000");
    
    Port ( hex1 : in STD_LOGIC_VECTOR (3 downto 0);
           hex2 : in STD_LOGIC_VECTOR (3 downto 0);
           hex3 : in STD_LOGIC_VECTOR (3 downto 0);
           hex4 : in STD_LOGIC_VECTOR (3 downto 0);
           hex5 : in STD_LOGIC_VECTOR (3 downto 0);
           hex6 : in STD_LOGIC_VECTOR (3 downto 0);
           hex7 : in STD_LOGIC_VECTOR (3 downto 0);
           hex8 : in STD_LOGIC_VECTOR (3 downto 0);
           clk : in STD_LOGIC;
           en : in STD_LOGIC;
           sseg: out STD_LOGIC_VECTOR (7 downto 0);
           an: out STD_LOGIC_VECTOR (7 downto 0)
     );
end sseg_display;

architecture arch of sseg_display is

component hex_to_sseg is
    Port ( hex : in STD_LOGIC_VECTOR (3 downto 0);
           dp: in STD_LOGIC;
           sseg : out STD_LOGIC_VECTOR (7 downto 0)
    );
end component;

component sseg_mux is
    Generic ( M: unsigned(3 downto 0) := "1000");
    
    Port ( in1 : in STD_LOGIC_VECTOR (7 downto 0);
           in2 : in STD_LOGIC_VECTOR (7 downto 0);
           in3 : in STD_LOGIC_VECTOR (7 downto 0);
           in4 : in STD_LOGIC_VECTOR (7 downto 0);
           in5 : in STD_LOGIC_VECTOR (7 downto 0);
           in6 : in STD_LOGIC_VECTOR (7 downto 0);
           in7 : in STD_LOGIC_VECTOR (7 downto 0);
           in8 : in STD_LOGIC_VECTOR (7 downto 0);
           clk : in STD_LOGIC;
           en: in STD_LOGIC;
           sseg : out STD_LOGIC_VECTOR (7 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0));
end component;

signal sseg1, sseg2, sseg3, sseg4, sseg5, sseg6, sseg7, sseg8: STD_LOGIC_VECTOR(7 downto 0); 
begin
    hex_to_sseg_inst1: hex_to_sseg port map (hex=>hex1, dp=>'1', sseg=>sseg1);
    hex_to_sseg_inst2: hex_to_sseg port map (hex=>hex2, dp=>'1', sseg=>sseg2);
    hex_to_sseg_inst3: hex_to_sseg port map (hex=>hex3, dp=>'1', sseg=>sseg3);
    hex_to_sseg_inst4: hex_to_sseg port map (hex=>hex4, dp=>'1', sseg=>sseg4);
    hex_to_sseg_inst5: hex_to_sseg port map (hex=>hex5, dp=>'1', sseg=>sseg5);
    hex_to_sseg_inst6: hex_to_sseg port map (hex=>hex6, dp=>'1', sseg=>sseg6);
    hex_to_sseg_inst7: hex_to_sseg port map (hex=>hex7, dp=>'1', sseg=>sseg7);
    hex_to_sseg_inst8: hex_to_sseg port map (hex=>hex8, dp=>'1', sseg=>sseg8);

    sseg_mux_inst: sseg_mux generic map (M=>N) port map (in1=>sseg1, in2=>sseg2, in3=>sseg3, in4=>sseg4, in5=>sseg5, in6=>sseg6, in7=>sseg7, in8=>sseg8, clk=>clk, en=>en, sseg=>sseg, an=>an);
end arch;

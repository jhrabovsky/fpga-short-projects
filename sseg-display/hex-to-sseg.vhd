----------------------------------------------------------------------------------
-- Company: University of Zilina 
-- Engineer: Jakub Hrabovsky
-- 
-- Create Date: 02.03.2016 19:59:20
-- Design Name: Hex to sseg translation 
-- Module Name: hex_to_sseg - arch
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

entity hex_to_sseg is
    Port ( hex : in STD_LOGIC_VECTOR (3 downto 0);
           dp: in STD_LOGIC;
           sseg : out STD_LOGIC_VECTOR (7 downto 0)
    );
end hex_to_sseg;

architecture arch of hex_to_sseg is
begin
    with hex select
        sseg(6 downto 0) <= "1000000" when "0000", 
                            "1111001" when "0001",
                            "0100100" when "0010",
                            "0110000" when "0011",
                            "0011001" when "0100",
                            "0010010" when "0101",
                            "0000010" when "0110",
                            "1111000" when "0111",
                            "0000000" when "1000",
                            "0010000" when "1001",
                            "0001000" when "1010",
                            "0000011" when "1011",
                            "1000110" when "1100",
                            "0100001" when "1101",
                            "0000110" when "1110",
                            "0001110" when "1111",
                            "1111111" when others;
    
    sseg(7) <= dp;
end arch;

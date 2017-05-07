----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02.03.2016 20:37:39
-- Design Name: 
-- Module Name: sseg_display_wrapper - Behavioral
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

entity sseg_display_wrapper is
    Port (
        CA: out STD_LOGIC;
        CB: out STD_LOGIC;
        CC: out STD_LOGIC;
        CD: out STD_LOGIC;
        CE: out STD_LOGIC;
        CF: out STD_LOGIC;
        CG: out STD_LOGIC;
        DP: out STD_LOGIC;
        AN: out STD_LOGIC_VECTOR(7 downto 0);
        CLK100MHZ: in STD_LOGIC;
        SW: in STD_LOGIC_VECTOR(15 downto 0)
    );
end sseg_display_wrapper;

architecture arch of sseg_display_wrapper is

component sseg_display is
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
end component;

signal tick: STD_LOGIC;
signal counter: UNSIGNED (16 downto 0);
constant M: UNSIGNED (16 downto 0) := "11000011010100000";

signal sseg_out: STD_LOGIC_VECTOR (7 downto 0);

begin
    counter_upd: process(CLK100MHZ)
    begin
        if (rising_edge(CLK100MHZ)) then
            if (counter >= M) then
                counter <= (others=>'0');
            else
                counter <= counter + 1;
            end if;
        end if;
    end process counter_upd;

    tick <= '1' when (counter = M) else
            '0';
    
    sseg_display_inst: sseg_display generic map(N=>"0100") port map (hex1=>SW(3 downto 0), hex2=>SW(7 downto 4), hex3=>SW(11 downto 8), hex4=>SW(15 downto 12), hex5=>"0000", hex6=>"0000", hex7=>"0000", hex8=>"0000", clk=>CLK100MHZ, en=>tick, sseg=>sseg_out, an=>AN);
    
    CA <= sseg_out(0);
    CB <= sseg_out(1); 
    CC <= sseg_out(2); 
    CD <= sseg_out(3); 
    CE <= sseg_out(4); 
    CF <= sseg_out(5); 
    CG <= sseg_out(6); 
    DP <= sseg_out(7);
      
end arch;

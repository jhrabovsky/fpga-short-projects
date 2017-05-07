
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
use std.textio.all;

entity dual_ram is
    generic (
        RAM_WIDTH_BITS : integer := 64;                      -- Specify RAM data width
        RAM_DEPTH_BITS : integer := 10                      
    );

    port (
        clk  : in std_logic;                       			            -- Clock
        addr_in : in std_logic_vector(RAM_DEPTH_BITS - 1 downto 0);     -- Write address bus, width determined from RAM_DEPTH
        addr_out : in std_logic_vector(RAM_DEPTH_BITS - 1 downto 0);    -- Read address bus, width determined from RAM_DEPTH
        din  : in std_logic_vector(RAM_WIDTH_BITS - 1 downto 0);	            -- RAM input data
        we   : in std_logic;                       			            -- Write enable
        dout : out std_logic_vector(RAM_WIDTH_BITS - 1  downto 0)               -- RAM output data
    );
end dual_ram;

architecture rtl of dual_ram is

type RAM_T is array (0 to RAM_DEPTH_BITS**2 - 1) of std_logic_vector(RAM_WIDTH_BITS - 1 downto 0);          -- 2D Array Declaration for RAM signal
signal ram_mem : RAM_T := (others => (others => '0'));
signal dout_next : std_logic_vector(RAM_WIDTH_BITS - 1 downto 0); 

attribute ram_style : string;
attribute ram_style of ram_mem : signal is "block";

begin

    write_proc : process(clk) is
    begin
        if(rising_edge(clk)) then
            if(we = '1') then
                ram_mem(to_integer(unsigned(addr_in))) <= din;
            end if;
            
            dout_next <= ram_mem(to_integer(unsigned(addr_out)));
        end if;
    end process;

    dout <= dout_next;

end rtl;

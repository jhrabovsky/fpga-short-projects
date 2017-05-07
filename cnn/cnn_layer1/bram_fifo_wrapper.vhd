
library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
    use UNISIM.VCOMPONENTS.ALL;

library UNIMACRO;
    use UNIMACRO.VCOMPONENTS.ALL;

entity bram_fifo_wrapper is
    Generic (
        DATA_LEN : natural := 8
    );
    Port (
        clk : in std_logic;
        rst : in std_logic;
        empty : out std_logic;
        full : out std_logic;
        rderr : out std_logic;
        wrerr : out std_logic;
        din : in std_logic_vector(DATA_LEN - 1 downto 0);
        wren : in std_logic;
        dout : out std_logic_vector(DATA_LEN - 1 downto 0);
        rden : in std_logic
    );      
end bram_fifo_wrapper;

architecture arch of bram_fifo_wrapper is

signal almost_empty, almost_full : std_logic;
signal dout_next, dout_reg : std_logic_vector(DATA_LEN - 1 downto 0);

begin

    regs_proc: process(clk) is
    begin 
        if (rising_edge(clk)) then
            if (rst = '1') then
                dout_reg <= (others => '0');
            else
                dout_reg <= dout_next;
            end if;
        end if;
    end process regs_proc;
     
    -- SOURCE: ug953-vivado-7series-libraries.pdf [p167]
       
    FIFO_BRAM_inst : FIFO_SYNC_MACRO
        generic map (
            DEVICE => "7SERIES",
            ALMOST_EMPTY_OFFSET => X"0001",
            ALMOST_FULL_OFFSET => X"0001",
            DATA_WIDTH => DATA_LEN,
            FIFO_SIZE => "18Kb",
            DO_REG => 0 -- ked pouzijem interny reg => vystup sa nezobrazuje, preto nahradim ext reg.
        )
        port map (
            almostempty => almost_empty,
            almostfull => almost_full,
            do => dout_next,
            empty => empty,
            full => full,
            rdcount => open,
            rderr => rderr,
            wrcount => open,
            wrerr => wrerr,
            clk => clk,
            di => din,
            rden => rden,
            rst => rst,
            wren => wren
        );

        
    dout <= dout_reg;
        
end arch;
